local FlipbookBatteries = require("@pkg/flipbook-batteries@v0.9.0")
local fs = require("@std/fs")
local json = require("@std/json")
local net = require("@std/net")
local process = require("@std/process")

local config = require("@root/config")
local constants = require("@root/constants")
local ensureStateDir = require("@root/ensureStateDir")

local run = FlipbookBatteries.run

local DEFAULT_REPO = "flipbook-labs/flipbook"
local DEFAULT_ASSET_NAME = "Flipbook.rbxm"

local function releaseApiUrl(repo: string, tag: string?): string
	if tag then
		return `https://api.github.com/repos/{repo}/releases/tags/{tag}`
	end
	return `https://api.github.com/repos/{repo}/releases/latest`
end

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

local function fetchRelease(repo: string, tag: string?): { tag_name: string, assets: { { name: string, browser_download_url: string } } }
	local response = net.request(releaseApiUrl(repo, tag), {
		method = "GET",
		headers = githubHeaders(),
	})

	if response.status >= 400 then
		error(`failed to fetch GitHub release ({response.status}): {response.body}`)
	end

	return json.deserialize(response.body) :: any
end

local function findAssetDownloadUrl(release: any, rbxmAssetName: string): string
	for _, asset in release.assets do
		if asset.name == rbxmAssetName then
			return asset.browser_download_url
		end
	end
	error(`release {release.tag_name} has no asset named "{rbxmAssetName}"`)
end

local function readCachedReleaseTag(): string?
	if not fs.exists(constants.FLIPBOOK_RELEASE_META) then
		return nil
	end
	local meta = json.deserialize(fs.readFileToString(constants.FLIPBOOK_RELEASE_META)) :: { tag_name: string? }
	return meta.tag_name
end

local function writeCachedReleaseTag(tagName: string)
	ensureStateDir()
	fs.writeStringToFile(constants.FLIPBOOK_RELEASE_META, json.serialize({ tag_name = tagName }, true))
end

local function fetchFlipbookRbxm(): string
	local repo = DEFAULT_REPO
	local rbxmAssetName = DEFAULT_ASSET_NAME
	local cachePath = constants.FLIPBOOK_RBXM_CACHE

	local cachedTag = readCachedReleaseTag()
	if fs.exists(cachePath) and cachedTag then
		print(`Using cached {rbxmAssetName} ({cachedTag})`)
		return cachePath
	end

	local release = fetchRelease(repo)
	local tagName = release.tag_name

	if fs.exists(cachePath) and cachedTag == tagName then
		print(`Using cached {rbxmAssetName} ({tagName})`)
		return cachePath
	end

	local downloadUrl = findAssetDownloadUrl(release, rbxmAssetName)
	print(`Downloading {rbxmAssetName} from {repo} release {tagName}...`)
	ensureStateDir()
	run(config.curlCmd, { "-fsSL", downloadUrl, "-o", cachePath })
	writeCachedReleaseTag(tagName)
	print(`Cached {rbxmAssetName} at {cachePath}`)

	return cachePath
end

return fetchFlipbookRbxm
