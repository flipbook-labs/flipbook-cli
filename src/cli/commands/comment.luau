local cli = require("@batteries/cli")
local process = require("@std/process")

local comment = require("@root/comment")
local resolveRobloxApiKey = require("@root/resolveRobloxApiKey")

local function help()
	print([[
flipbook-cli comment
Post or update the storybook preview comment on a pull request.

USAGE:
  flipbook-cli comment [options]

REQUIRED:
  --pr <number>              Pull request number
  --universe-id <id>         Experience (universe) ID
  --place-id <id>            Root place ID

OPTIONS:
  --name <name>              Deploy place name (default: pr-<number>)
  --api-key, -k <key>        Roblox API key (default: ROBLOX_API_KEY)
  --help                     Show this help message

ENV VARS:
  ROBLOX_API_KEY             Roblox API key (when --api-key is not passed)
  GITHUB_TOKEN               GitHub token
  GITHUB_REPOSITORY          owner/repo
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
		required = true,
	})
	parser:add("place-id", "option", {
		help = "Root place ID",
		required = true,
	})
	parser:add("api-key", "option", {
		aliases = { "k" },
		help = "Roblox API key (default: ROBLOX_API_KEY)",
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
		apiKey = resolveRobloxApiKey(parser:get("api-key")),
	})
end

return { run = run }
