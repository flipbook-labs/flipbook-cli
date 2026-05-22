local cli = require("@batteries/cli")
local process = require("@std/process")

local comment = require("@root/comment")
local helpText = require("@root/cli/helpText")

local DESCRIPTION = "Post or update a PR preview comment"

local HELP: helpText.HelpConfig = {
	title = "comment",
	summary = "Post or update the storybook preview comment on a pull request.",
	env = {
		{
			vars = {
				{ name = "GITHUB_TOKEN", description = "GitHub token", required = true },
				{ name = "GITHUB_REPOSITORY", description = "owner/repo", required = true },
			},
		},
	},
}

local function run(args: { string })
	local parser = cli.parser()

	parser:add("pr", "option", {
		help = "Pull request number",
		required = true,
	})
	parser:add("name", "option", {
		help = "Deploy name",
	})
	parser:add("help", "flag", {
		help = "Show this help message",
	})

	parser:parse(args)

	if parser:has("help") then
		helpText.print(parser, HELP)
		process.exit(0)
	end

	local prNumber = assert(tonumber(parser:get("pr")), "--pr must be a number")
	local name = parser:get("name") or `pr-{prNumber}`

	local githubToken = assert(process.env.GITHUB_TOKEN, "GITHUB_TOKEN environment variable is required")
	local repo = assert(process.env.GITHUB_REPOSITORY, "GITHUB_REPOSITORY environment variable is required")

	comment({
		prNumber = prNumber,
		name = name,
		githubToken = githubToken,
		repo = repo,
	})
end

return {
	run = run,
	description = DESCRIPTION,
}
