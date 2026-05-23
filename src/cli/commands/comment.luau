local cli = require("@batteries/cli")
local json = require("@std/json")
local net = require("@std/net")
local process = require("@std/process")

local storybookPreviewUrl = require("@root/storybookPreviewUrl")
local types = require("@root/cli/types")

local PR_COMMENT_MARKER = "<!-- flipbook-pr-preview -->"

local title = "comment"
local summary = "Post or update the storybook preview comment on a pull request."

local parser = cli.parser()

parser:add("pr", "option", {
	help = "Pull request number",
	required = true,
})
parser:add("github-token", "option", {
	help = "GitHub token (Can also be supplied by the GITHUB_TOKEN env var)",
	default = process.env.GITHUB_TOKEN,
	required = true,
})
parser:add("github-repository", "option", {
	help = "owner/repo (Can also be supplied by the GITHUB_REPOSITORY env var)",
	default = process.env.GITHUB_REPOSITORY,
	required = true,
})
parser:add("name", "option", {
	help = "Deploy name",
})
parser:add("place-id", "option", {
	help = "Place ID of the deployed storybook.",
	required = true,
})
parser:add("help", "flag", {
	help = "Show this help message",
})

local function run(args: { string })
	parser:parse(args)

	local prNumber = assert(tonumber(parser:get("pr")), "--pr must be a number")
	local name = parser:get("name") or `pr-{prNumber}`
	local githubToken = assert(
		parser:get("github-token"),
		"A GitHub token is required, use --github-token or the GITHUB_TOKEN env var to supply it"
	)
	local repo = assert(
		parser:get("github-repository"),
		"A GitHub repository (owner/repo) is required, use --github-repository or the GITHUB_REPOSITORY env var"
	)
	local placeId = assert(tonumber(parser:get("place-id")), "--place-id must be a number")

	local timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
	local body = PR_COMMENT_MARKER
		.. "\n## Storybook Preview\n\n"
		.. "| | Link |\n|--|------|\n"
		.. "| Play | [Open in Roblox]("
		.. storybookPreviewUrl(placeId)
		.. ") |\n\n"
		.. "*Place `"
		.. name
		.. "` · "
		.. timestamp
		.. "*"

	local headers: { [string]: string } = {
		Authorization = "Bearer " .. githubToken,
		Accept = "application/vnd.github+json",
		["Content-Type"] = "application/json",
	}

	local listResponse = net.request(
		"https://api.github.com/repos/" .. repo .. "/issues/" .. prNumber .. "/comments?per_page=100",
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
			"https://api.github.com/repos/" .. repo .. "/issues/comments/" .. existingId,
			{ method = "PATCH", headers = headers, body = payload }
		)
	else
		net.request(
			"https://api.github.com/repos/" .. repo .. "/issues/" .. prNumber .. "/comments",
			{ method = "POST", headers = headers, body = payload }
		)
	end
end

local command: types.Command = {
	run = run,
	title = title,
	summary = summary,
	parser = parser,
}

return command
