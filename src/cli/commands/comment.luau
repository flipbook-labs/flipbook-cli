local cli = require("@batteries/cli")
local process = require("@std/process")

local comment = require("@root/comment")
local helpText = require("@root/cli/helpText")
local types = require("@root/cli/types")

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
parser:add("help", "flag", {
	help = "Show this help message",
})

local function run(args: { string })
	parser:parse(args)

	if parser:has("help") then
		helpText.print(parser, { title = title, summary = summary })
		process.exit(0)
	end

	local prNumber = assert(tonumber(parser:get("pr")), "--pr must be a number")
	local name = parser:get("name") or `pr-{prNumber}`

	comment({
		prNumber = prNumber,
		name = name,
		githubToken = parser:get("github-token") :: string,
		repo = parser:get("github-repository") :: string,
	})
end

local command: types.Command = {
	run = run,
	title = title,
	summary = summary,
	parser = parser,
}

return command
