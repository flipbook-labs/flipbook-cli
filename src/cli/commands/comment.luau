local cli = require("@batteries/cli")
local process = require("@std/process")

local comment = require("@root/comment")

local function help()
	print([[
flipbook-cli comment
Post or update the storybook preview comment on a pull request.

USAGE:
  flipbook-cli comment [options]

REQUIRED:
  --pr <number>              Pull request number

OPTIONS:
  --name <name>              Deploy place name (default: pr-<number>)
  --universe-id <id>         Experience (universe) ID. Defaults to ROBLOX_STORYBOOK_UNIVERSE_ID if it exists.
  --place-id <id>            Root place ID. Defaults to ROBLOX_STORYBOOK_PLACE_ID if it exists.
  --help                     Show this help message

ENV VARS:
  ROBLOX_API_KEY               Roblox API key (resolves place by name)
  ROBLOX_STORYBOOK_UNIVERSE_ID Experience (universe) ID
  ROBLOX_STORYBOOK_PLACE_ID    Root place ID
  GITHUB_TOKEN                 GitHub token
  GITHUB_REPOSITORY            owner/repo
]])
end

local function run(args: { string })
	local parser = cli.parser()

	parser:add("pr", "option", {
		help = "PR number",
	})
	parser:add("name", "option", {
		help = "Deploy place name",
	})
	parser:add("universe-id", "option", {
		help = "Experience (universe) ID",
	})
	parser:add("place-id", "option", {
		help = "Root place ID",
	})
	parser:add("help", "flag", {
		help = "Shows this help message",
	})

	parser:parse(args)

	if parser:has("help") then
		help()
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
		universeId = parser:get("universe-id"),
		placeId = parser:get("place-id"),
	})
end

return {
	run = run,
	help = help,
}
