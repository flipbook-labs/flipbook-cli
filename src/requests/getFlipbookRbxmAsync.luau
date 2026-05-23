local fs = require("@std/fs")
local json = require("@std/json")
local path = require("@std/path")

local fetch = require("@root/requests/fetch")
local githubHeaders = require("@root/requests/githubHeaders")
local getTempDir = require("@root/getTempDir")
local logging = require("@root/logging")

local GITHUB_REPO = "flipbook-labs/flipbook"
local RBXM_ASSET_NAME = "Flipbook.rbxm"

local function getReleaseAsync(): { tag_name: string, assets: { { name: string, browser_download_url: string } } }
	local res = fetch(`https://api.github.com/repos/{GITHUB_REPO}/releases/latest`, {
		headers = githubHeaders(),
	})

	return json.deserialize(res.body) :: any
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

	logging.info(`Downloading {RBXM_ASSET_NAME} from {GITHUB_REPO} release {release.tag_name}...`)

	local res = fetch(downloadUrl, {
		headers = githubHeaders(),
	})

	local flipbookRbxmPath = tostring(path.join(getTempDir(), "Flipbook.rbxm"))
	fs.writeStringToFile(flipbookRbxmPath, res.body)

	return flipbookRbxmPath
end

return getFlipbookRbxmAsync
