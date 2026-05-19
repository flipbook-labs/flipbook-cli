local cli = require("@batteries/cli")
local process = require("@std/process")

local comment = require("@root/comment")

local function help()
	print([[
deploy-storybook comment
Post or update the storybook preview comment on a pull request.

USAGE:
  deploy-storybook comment [options]

REQUIRED:
  --pr <number>              Pull request number
  --place-id <id>            Roblox Place ID (or set ROBLOX_STORYBOOK_PLACE_ID)

ENV VARS:
  ROBLOX_STORYBOOK_PLACE_ID  Fallback for --place-id
  GITHUB_TOKEN               GitHub token for posting comments
  GITHUB_REPOSITORY          GitHub repository (owner/repo)

FLAGS:
  --help                     Show this help message
]])
end

local function run(args: { string })
	local parser = cli.parser()

	parser:add("pr", "option", { help = "PR number" })
	parser:add("place-id", "option", { help = "Roblox Place ID" })
	parser:add("help", "flag")

	parser:parse(args)

	if parser:has("help") then
		help()
		process.exit(0)
	end

	local prNumber = assert(tonumber(parser:get("pr")), "--pr must be a number")

	local placeId = parser:get("place-id") or process.env.ROBLOX_STORYBOOK_PLACE_ID
	assert(placeId, "place-id must be provided via --place-id or ROBLOX_STORYBOOK_PLACE_ID env var")

	local githubToken = assert(process.env.GITHUB_TOKEN, "GITHUB_TOKEN environment variable is required")
	local repo = assert(process.env.GITHUB_REPOSITORY, "GITHUB_REPOSITORY environment variable is required")

	comment({
		prNumber = prNumber,
		placeId = placeId,
		githubToken = githubToken,
		repo = repo,
	})
end

return { run = run }
