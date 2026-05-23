local fs = require("@std/fs")
local json = require("@std/json")
local net = require("@std/net")
local path = require("@std/path")
local process = require("@std/process")

local getTempDir = require("@root/getTempDir")

local GITHUB_REPO = "flipbook-labs/flipbook"
local RBXM_ASSET_NAME = "Flipbook.rbxm"
local RELEASES_API = `https://api.github.com/repos/{GITHUB_REPO}/releases`

export type FetchFlipbookRbxmOptions = {
	tag: string?,
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

local function normalizeTag(tag: string): string
	if string.sub(tag, 1, 1) == "v" then
		return tag
	end
	return "v" .. tag
end

local function releaseApiUrl(options: FetchFlipbookRbxmOptions?): string
	local tag = options and options.tag
	if tag == nil or tag == "" then
		return `{RELEASES_API}/latest`
	end
	return `{RELEASES_API}/tags/{normalizeTag(tag)}`
end

local function fetchRelease(options: FetchFlipbookRbxmOptions?): { tag_name: string, assets: { { name: string, browser_download_url: string } } }
	local url = releaseApiUrl(options)
	local response = net.request(url, {
		method = "GET",
		headers = githubHeaders(),
	})

	if response.status >= 400 then
		error(`failed to fetch GitHub release ({response.status}): {response.body}`)
	end

	return json.deserialize(response.body) :: any
end

local function findAssetDownloadUrl(release: any): string
	for _, asset in release.assets do
		if asset.name == RBXM_ASSET_NAME then
			return asset.browser_download_url
		end
	end
	error(`release {release.tag_name} has no asset named "{RBXM_ASSET_NAME}"`)
end

local function fetchFlipbookRbxm(options: FetchFlipbookRbxmOptions?): string
	local release = fetchRelease(options)
	local downloadUrl = findAssetDownloadUrl(release)

	print(`Downloading {RBXM_ASSET_NAME} from {GITHUB_REPO} release {release.tag_name}...`)

	local response = net.request(downloadUrl, {
		method = "GET",
		headers = githubHeaders(),
	})

	if response.status >= 400 then
		error(`failed to download {RBXM_ASSET_NAME} ({response.status})`)
	end

	local flipbookRbxmPath = tostring(path.join(getTempDir(), RBXM_ASSET_NAME))
	fs.writeStringToFile(flipbookRbxmPath, response.body)

	return flipbookRbxmPath
end

return fetchFlipbookRbxm
