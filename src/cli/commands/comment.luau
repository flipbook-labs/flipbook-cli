local cli = require("@batteries/cli")
local process = require("@std/process")

local storybookPreviewUrl = require("@root/storybookPreviewUrl")
local syncPrCommentAsync = require("@root/requests/syncPrCommentAsync")
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

local function run()
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
		.. storybookPreviewUrl(placeId, placeId)
		.. ") |\n\n"
		.. "*Place `"
		.. name
		.. "` · "
		.. timestamp
		.. "*"

	syncPrCommentAsync(repo, prNumber, githubToken, body)
end

local command: types.Command = {
	run = run,
	title = title,
	summary = summary,
	parser = parser,
}

return command
