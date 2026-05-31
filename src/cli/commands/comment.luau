local cli = require("@batteries/cli")
local json = require("@std/json")
local process = require("@std/process")

local githubRequest = require("@root/requests/githubRequest")
local storybookPreviewUrl = require("@root/storybookPreviewUrl")
local types = require("@root/cli/types")

local PR_COMMENT_MARKER = "<!-- flipbook-pr-preview -->"

local title = "comment"
local summary = "Post or update the storybook preview comment on a pull request."

local parser = cli.parser()

parser:add("pr", "option", {
	help = "Pull request number to comment on.",
	required = true,
})
parser:add("place-id", "option", {
	help = "Place ID of the deployed storybook preview.",
	required = true,
})
parser:add("start-place-id", "option", {
	help = "Start place ID players launch into. Used to build the deep link.",
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
parser:add("help", "flag", {
	help = "Show this help message",
})

local function run()
	local prNumber = assert(tonumber(parser:get("pr")), "--pr must be a number")
	local placeId = assert(tonumber(parser:get("place-id")), "--place-id must be a number")
	local startPlaceId = assert(tonumber(parser:get("start-place-id")), "--start-place-id must be a number")
	local githubToken = assert(
		parser:get("github-token"),
		"A GitHub token is required, use --github-token or the GITHUB_TOKEN env var to supply it"
	)
	local repo = assert(
		parser:get("github-repository"),
		"A GitHub repository (owner/repo) is required, use --github-repository or the GITHUB_REPOSITORY env var"
	)

	local previewUrl = storybookPreviewUrl(startPlaceId, placeId)

	local timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
	local body = PR_COMMENT_MARKER
		.. "\n## Storybook Preview\n\n"
		.. "| | Link |\n|--|------|\n"
		.. "| Play | [Open in Roblox]("
		.. previewUrl
		.. ") |\n\n"
		.. "*Updated "
		.. timestamp
		.. "*"

	local existingId: number? = nil
	local page = 1
	while not existingId do
		local comments = githubRequest(
			`https://api.github.com/repos/{repo}/issues/{prNumber}/comments?per_page=100&page={page}`,
			{ token = githubToken }
		) :: { any }
		if type(comments) ~= "table" then
			break
		end
		for _, comment in comments do
			if type(comment.body) == "string" and (comment.body :: string):find(PR_COMMENT_MARKER, 1, true) then
				existingId = comment.id :: number
				break
			end
		end
		if #comments < 100 then
			break
		end
		page += 1
	end

	local payload = json.serialize({ body = body })
	if existingId then
		githubRequest(`https://api.github.com/repos/{repo}/issues/comments/{existingId}`, {
			token = githubToken,
			method = "PATCH",
			body = payload,
		})
		print(`Updated storybook preview comment on PR #{prNumber} (comment {existingId}).`)
	else
		githubRequest(`https://api.github.com/repos/{repo}/issues/{prNumber}/comments`, {
			token = githubToken,
			method = "POST",
			body = payload,
		})
		print(`Posted storybook preview comment on PR #{prNumber}.`)
	end
end

local command: types.Command = {
	run = run,
	title = title,
	summary = summary,
	parser = parser,
}

return command
