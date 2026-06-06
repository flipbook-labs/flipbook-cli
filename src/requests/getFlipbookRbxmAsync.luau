local fs = require("@std/fs")
local json = require("@std/json")
local net = require("@std/net")
local path = require("@std/path")
local process = require("@std/process")

local getTempDir = require("@root/getTempDir")

local GITHUB_REPO = "flipbook-labs/flipbook"
local RBXM_ASSET_NAME = "Flipbook.rbxm"

type GitHubReleaseAsset = {
	name: string,
	browserDownloadUrl: string,
}

type GitHubRelease = {
	tagName: string,
	assets: { GitHubReleaseAsset },
}

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

local function getReleaseAsync(): GitHubRelease
	local url = `https://api.github.com/repos/{GITHUB_REPO}/releases/latest`
	local response = net.request(url, {
		method = "GET",
		headers = githubHeaders(),
	})

	if response.status >= 400 then
		error(`failed to fetch GitHub release ({response.status}): {response.body}`)
	end

	local body = json.deserialize(response.body)

	local obj = json.asObject(body)
	local tagName = if obj then tostring(obj.tag_name) else nil
	local assets = if obj then json.asArray(obj.assets) else nil

	if tagName and assets then
		local validAssets = {}
		for _, asset in assets do
			local assetObj = json.asObject(asset)
			if assetObj and assetObj.name and assetObj.browser_download_url then
				table.insert(validAssets, {
					name = tostring(assetObj.name),
					browserDownloadUrl = tostring(assetObj.browser_download_url),
				})
			end
		end

		return {
			tagName = tagName,
			assets = validAssets,
		}
	end
	error("failed to parse GitHub release")
end

local function findAssetDownloadUrl(release: GitHubRelease): string
	for _, asset in release.assets do
		if asset.name == RBXM_ASSET_NAME then
			return asset.browserDownloadUrl
		end
	end
	error(`release {release.tagName} has no asset named "{RBXM_ASSET_NAME}"`)
end

local function getFlipbookRbxmAsync(): string
	local release = getReleaseAsync()
	local downloadUrl = findAssetDownloadUrl(release)

	print(`Downloading Flipbook {release.tagName} from {GITHUB_REPO} releases...`)

	local response = net.request(downloadUrl, {
		method = "GET",
		headers = githubHeaders(),
	})

	if response.status >= 400 then
		error(`failed to download {RBXM_ASSET_NAME} ({response.status})`)
	end

	local flipbookRbxmPath = tostring(path.join(getTempDir(), "Flipbook.rbxm"))
	fs.writeStringToFile(flipbookRbxmPath, response.body)

	return flipbookRbxmPath
end

return getFlipbookRbxmAsync
