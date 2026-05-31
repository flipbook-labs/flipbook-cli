local cli = require("@batteries/cli")
local json = require("@std/json")
local process = require("@std/process")

local getPlaceIdByNameAsync = require("@root/requests/getPlaceIdByNameAsync")
local getUniverseStartPlaceAsync = require("@root/requests/getUniverseStartPlaceAsync")
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
parser:add("universe-id", "option", {
	help = "Universe the preview place lives in.",
	required = true,
})
parser:add("place-name", "option", {
	help = "Name of the deployed preview place. Resolved to a place ID to build the link.",
	required = true,
})
parser:add("api-key", "option", {
	help = "Roblox API key (Can also be supplied by the ROBLOX_API_KEY env var)",
	default = process.env.ROBLOX_API_KEY,
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
	local universeId = assert(tonumber(parser:get("universe-id")), "--universe-id must be a number")
	local placeName = parser:get("place-name") :: string
	local apiKey = assert(
		parser:get("api-key"),
		"A Roblox API key is required, use --api-key or the ROBLOX_API_KEY env var to supply it"
	)
	local githubToken = assert(
		parser:get("github-token"),
		"A GitHub token is required, use --github-token or the GITHUB_TOKEN env var to supply it"
	)
	local repo = assert(
		parser:get("github-repository"),
		"A GitHub repository (owner/repo) is required, use --github-repository or the GITHUB_REPOSITORY env var"
	)

	local targetPlaceId = assert(
		getPlaceIdByNameAsync(universeId, placeName, apiKey),
		`Could not find a place named "{placeName}" in universe {universeId}`
	)
	local startPlaceId = getUniverseStartPlaceAsync(universeId, apiKey)
	local previewUrl = storybookPreviewUrl(startPlaceId, targetPlaceId)

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
