local fs = require("@std/fs")
local json = require("@std/json")
local net = require("@std/net")
local path = require("@std/path")
local process = require("@std/process")

local getTempDir = require("@root/getTempDir")

local GITHUB_REPO = "flipbook-labs/flipbook"
local RBXM_ASSET_NAME = "Flipbook.rbxm"

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

	return json.deserialize(response.body)
end

local function findAssetDownloadUrl(release: any): string
	for _, asset in release.assets do
		if asset.name == RBXM_ASSET_NAME then
			return asset.browser_download_url
		end
	end
	error(`release {release.tag_name} has no asset named "{RBXM_ASSET_NAME}"`)
end

local function getFlipbookRbxmAsync(): string
	local release = getReleaseAsync()
	local downloadUrl = findAssetDownloadUrl(release)

	print(`Downloading Flipbook {release.tag_name} from {GITHUB_REPO} releases...`)

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
