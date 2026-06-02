local json = require("@std/json")
local net = require("@std/net")
local process = require("@std/process")

local GITHUB_REPO = "flipbook-labs/flipbook"
local ASSET_ID_FILE = "flipbook-model-asset-id.txt"

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

local function getReleaseAsync(): { tag_name: string, assets: { { name: string, browser_download_url: string } } }
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

	local downloadUrl: string?
	for _, asset in release.assets do
		if asset.name == ASSET_ID_FILE then
			downloadUrl = asset.browser_download_url
			break
		end
	end

	assert(downloadUrl, `release {release.tag_name} has no asset named "{ASSET_ID_FILE}"`)

	local response = net.request(downloadUrl :: string, {
		method = "GET",
		headers = githubHeaders(),
	})

	if response.status >= 400 then
		error(`failed to download {ASSET_ID_FILE} ({response.status})`)
	end

	local assetId = tonumber(response.body:match("%d+"))
	assert(assetId, `{ASSET_ID_FILE} in release {release.tag_name} did not contain a valid asset ID`)

	return assetId :: number
end

return getFlipbookAssetIdAsync
