local fs = require("@std/fs")
local json = require("@std/json")
local net = require("@std/net")
local toml = require("@batteries/toml")

local PR_COMMENT_MARKER = "<!-- flipbook-pr-preview -->"

local function readWallyVersion(): string
	local manifest = toml.deserialize(fs.readFileToString("wally.toml")) :: any
	return tostring(manifest.package.version)
end

export type CommentOptions = {
	prNumber: number,
	placeId: string,
	githubToken: string,
	repo: string,
}

local function comment(options: CommentOptions)
	local runtimeVersion = readWallyVersion()

	local encodedRoot = "storyRoot%3DPRStorybooks%2Fpr-" .. options.prNumber
	local prUrl = "https://www.roblox.com/games/" .. options.placeId .. "?launchData=" .. encodedRoot
	local allUrl = "https://www.roblox.com/games/" .. options.placeId
	local timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
	local body = PR_COMMENT_MARKER
		.. "\n## Storybook Preview\n\n"
		.. "| | Link |\n|--|------|\n"
		.. "| This PR | [Open in Roblox]("
		.. prUrl
		.. ") |\n"
		.. "| All open PRs | [Browse all]("
		.. allUrl
		.. ") |\n\n"
		.. "*Runtime v"
		.. runtimeVersion
		.. " · "
		.. timestamp
		.. "*"

	local headers: { [string]: string } = {
		Authorization = "Bearer " .. options.githubToken,
		Accept = "application/vnd.github+json",
		["Content-Type"] = "application/json",
	}

	local listResponse = net.request(
		"https://api.github.com/repos/" .. options.repo .. "/issues/" .. options.prNumber .. "/comments?per_page=100",
		{ method = "GET", headers = headers }
	)
	local comments = json.deserialize(listResponse.body) :: any
	local existingId: number? = nil
	for _, c in comments do
		if (c.body :: string):find(PR_COMMENT_MARKER, 1, true) then
			existingId = c.id :: number
			break
		end
	end

	local payload = json.serialize({ body = body })
	if existingId then
		net.request(
			"https://api.github.com/repos/" .. options.repo .. "/issues/comments/" .. existingId,
			{ method = "PATCH", headers = headers, body = payload }
		)
	else
		net.request(
			"https://api.github.com/repos/" .. options.repo .. "/issues/" .. options.prNumber .. "/comments",
			{ method = "POST", headers = headers, body = payload }
		)
	end
end

return comment
