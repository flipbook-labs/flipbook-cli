local path = require("@std/path")
local system = require("@std/system")

local buildPlace = require("@root/buildPlace")
local fetchFlipbookRbxm = require("@root/fetchFlipbookRbxm")
local loadStorybookConfig = require("@root/storybookConfig")
local publishPlace = require("@root/publishPlace")
local resolvePlaceId = require("@root/resolvePlaceId")
local storybookPreviewUrl = require("@root/storybookPreviewUrl")

export type DeployOptions = {
	name: string,
	storiesPath: string?,
	flipbookRbxmPath: string?,
	universeId: string?,
	placeId: string?,
	apiKey: string?,
	dryRun: string?,
}

local function resolveFlipbookRbxmPath(explicitPath: string?): string
	if explicitPath then
		return tostring(path.resolve(explicitPath))
	end

	return fetchFlipbookRbxm()
end

local function deploy(options: DeployOptions)
	local flipbookRbxmPath = resolveFlipbookRbxmPath(options.flipbookRbxmPath)
	local rbxlPath = options.dryRun or tostring(path.join(system.tmpdir(), `storybook-{options.name}.rbxl`))

	buildPlace({
		name = `FlipbookStorybook-{options.name}`,
		flipbookRbxmPath = flipbookRbxmPath,
		storiesPath = options.storiesPath,
		outputRbxlPath = rbxlPath,
	})

	if options.dryRun then
		print(`Built {rbxlPath}`)
		return
	end

	local apiKey = assert(options.apiKey, "API key is required")
	local storybook = loadStorybookConfig({
		universeId = options.universeId,
		placeId = options.placeId,
	})
	local placeId, created = resolvePlaceId(options.name, storybook, apiKey)
	publishPlace(storybook.universeId, placeId, rbxlPath, apiKey)

	print(`Published storybook "{options.name}" to place {placeId} (created={created})`)
	print("Play: " .. storybookPreviewUrl(placeId))
end

return deploy
