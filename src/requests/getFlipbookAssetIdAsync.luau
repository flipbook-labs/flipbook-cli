local json = require("@std/json")
local net = require("@std/net")
local process = require("@std/process")

local GITHUB_REPO = "flipbook-labs/flipbook"

-- Release artifacts are named Flipbook-{version}-{assetId}.rbxm so the
-- Roblox asset ID can be recovered from the filename alone.
local RUNTIME_ARTIFACT_PATTERN = "^Flipbook%-[^%-]+%-(%d+)%.rbxm$"

local function githubHeaders(): { [string]: string }
	local headers: { [string]: string } = {
		Accept = "application/vnd.github+json",
		["User-Agent"] = "flipbook-cli",
	}
	local token = process.env.GITHUB_TOKEN
	if token then
		headers.Authorization = `Bearer {token}`
	end
	return headers
end

local function getReleaseAsync(): { tag_name: string, assets: { { name: string } } }
	local url = `https://api.github.com/repos/{GITHUB_REPO}/releases/latest`
	local response = net.request(url, {
		method = "GET",
		headers = githubHeaders(),
	})

	if response.status >= 400 then
		error(`failed to fetch GitHub release ({response.status}): {response.body}`)
	end

	return json.deserialize(response.body) :: any
end

local function getFlipbookAssetIdAsync(): number
	local release = getReleaseAsync()

	for _, asset in release.assets do
		local assetId = asset.name:match(RUNTIME_ARTIFACT_PATTERN)
		if assetId then
			local id = tonumber(assetId)
			assert(id, `malformed asset ID in release artifact name "{asset.name}"`)
			return id :: number
		end
	end

	error(
		`release {release.tag_name} has no Flipbook-{{version}}-{{assetId}}.rbxm artifact`
	)
end

return getFlipbookAssetIdAsync
