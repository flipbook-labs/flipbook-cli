local FlipbookBatteries = require("@pkg/flipbook-batteries@v0.9.0")
local fs = require("@std/fs")
local json = require("@std/json")
local net = require("@std/net")
local path = require("@std/path")
local process = require("@std/process")
local system = require("@std/system")
local task = require("@std/task")

local config = require("@root/config")
local createRojoProject = require("@root/createRojoProject")
local readWallyVersion = require("@root/readWallyVersion")
local runTask = require("@root/runTask")
local storybookPreviewUrl = require("@root/storybookPreviewUrl")
local deployStorybookScript = require("@root/tasks/deploy-storybook")
local upgradeRuntimeScript = require("@root/tasks/upgrade-runtime")

local run = FlipbookBatteries.run
local buildRbxm = createRojoProject.buildRbxm

local RUNTIME_VERSION_VARIABLE = "STORYBOOK_RUNTIME_VERSION"
local function semverGt(a: string, b: string): boolean
	local function parse(v: string): { number }
		local parts: { number } = {}
		for seg in v:gmatch("[^%.]+") do
			table.insert(parts, tonumber(seg) or 0)
		end
		return parts
	end
	local pa, pb = parse(a), parse(b)
	for i = 1, math.max(#pa, #pb) do
		local x, y = pa[i] or 0, pb[i] or 0
		if x > y then
			return true
		elseif x < y then
			return false
		end
	end
	return false
end

local function uploadModel(rbxmPath: string, displayName: string, apiKey: string, creatorUserId: string): string
	local requestJson = json.serialize({
		assetType = "Model",
		displayName = displayName,
		description = "",
		creationContext = { creator = { userId = creatorUserId } },
	})
	local requestJsonPath = rbxmPath .. ".request.json"
	fs.writeStringToFile(requestJsonPath, requestJson)

	local uploadOutput = run(config.curlCmd, {
		"-s",
		"-X",
		"POST",
		"https://apis.roblox.com/assets/v1/assets",
		"-H",
		"x-api-key: " .. apiKey,
		"-F",
		"request=@" .. requestJsonPath .. ";type=application/json",
		"-F",
		"fileContent=@" .. rbxmPath .. ";type=application/octet-stream",
	}, { captureOutput = true })
	fs.remove(requestJsonPath)

	assert(uploadOutput and uploadOutput ~= "", "empty response from Assets API upload")
	local uploadData = json.deserialize(uploadOutput) :: any
	local operationId = tostring(uploadData.operationId)
	assert(operationId ~= "nil", "missing operationId in Assets API response: " .. uploadOutput)

	for _ = 1, 30 do
		task.wait(3)
		local pollResponse = net.request("https://apis.roblox.com/assets/v1/operations/" .. operationId, {
			method = "GET",
			headers = { ["x-api-key"] = apiKey },
		})
		local pollData = json.deserialize(pollResponse.body) :: any
		if pollData.done then
			return tostring((pollData.response :: any).assetId)
		end
	end

	error("asset upload timed out for operation " .. operationId)
end

local function getCreatorUserId(universeId: string, apiKey: string): string
	local response = net.request("https://apis.roblox.com/cloud/v2/universes/" .. universeId, {
		method = "GET",
		headers = { ["x-api-key"] = apiKey },
	})
	local data = json.deserialize(response.body) :: any
	-- User-owned universes have "user": "users/12345"
	local userId = tostring(data.user or ""):match("users/(%d+)")
	return assert(userId, "could not determine creator user ID from universe " .. universeId)
end

local function getDeployedRuntimeVersion(repo: string, token: string): string
	local response =
		net.request("https://api.github.com/repos/" .. repo .. "/actions/variables/" .. RUNTIME_VERSION_VARIABLE, {
			method = "GET",
			headers = {
				Authorization = "Bearer " .. token,
				Accept = "application/vnd.github+json",
			},
		})
	if response.status == 404 then
		return "0.0.0"
	end
	local data = json.deserialize(response.body) :: any
	return tostring(data.value)
end

export type DeployOptions = {
	prNumber: number,
	universeId: string,
	placeId: string,
	apiKey: string,
	githubToken: string?,
	repo: string?,
}

local function deploy(options: DeployOptions)
	local creatorUserId = getCreatorUserId(options.universeId, options.apiKey)
	local tmpDir = tostring(system.tmpdir())
	local cwd = tostring(process.cwd())

	run(config.luteCmd, { "run", "build", "plugin", "--channel", "dev", "--clean" })

	local prRbxm = path.join(tmpDir, "pr-" .. options.prNumber .. ".rbxm")
	buildRbxm("pr-" .. options.prNumber, path.join(cwd, "build", "dev", "roblox"), prRbxm)

	local storybookAssetId = assert(
		tonumber(uploadModel(prRbxm, "pr-" .. options.prNumber, options.apiKey, creatorUserId)),
		"invalid storybookAssetId returned from Assets API"
	)

	local currentVersion = readWallyVersion()
	local upgradeRuntime = if options.repo and options.githubToken
		then semverGt(currentVersion, getDeployedRuntimeVersion(options.repo, options.githubToken))
		else false

	runTask(
		deployStorybookScript,
		{ PR_NUMBER = options.prNumber, STORYBOOK_ASSET_ID = storybookAssetId },
		options.universeId,
		options.placeId,
		options.apiKey
	)

	if upgradeRuntime then
		run(config.luteCmd, { "run", "build", "plugin", "--channel", "prod", "--clean" })
		local runtimeRbxm = path.join(tmpDir, "runtime.rbxm")
		buildRbxm("Flipbook", path.join(cwd, "build", "prod", "roblox"), runtimeRbxm)
		local runtimeAssetId = assert(
			tonumber(uploadModel(runtimeRbxm, "Flipbook", options.apiKey, creatorUserId)),
			"invalid runtimeAssetId returned from Assets API"
		)
		runTask(
			upgradeRuntimeScript,
			{ RUNTIME_ASSET_ID = runtimeAssetId },
			options.universeId,
			options.placeId,
			options.apiKey
		)
		if options.repo then
			run(config.ghCmd, {
				"variable",
				"set",
				RUNTIME_VERSION_VARIABLE,
				"--repo",
				options.repo,
				"--body",
				currentVersion,
			})
		end
	end

	print("Storybook ready: " .. storybookPreviewUrl(options.prNumber, options.placeId))
end

return deploy
