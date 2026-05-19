local cli = require("@batteries/cli")
local process = require("@std/process")

local deploy = require("@root/deploy")

local function help()
	print([[
deploy-storybook deploy
Build and deploy a storybook for a pull request.

USAGE:
  deploy-storybook deploy [options]

REQUIRED:
  --pr <number>              Pull request number

OPTIONS:
  --universe-id <id>         Roblox Universe ID (or set ROBLOX_STORYBOOK_UNIVERSE_ID)
  --place-id <id>            Roblox Place ID (or set ROBLOX_STORYBOOK_PLACE_ID)

ENV VARS (required):
  ROBLOX_API_KEY             Roblox API key

ENV VARS (optional):
  ROBLOX_STORYBOOK_UNIVERSE_ID  Fallback for --universe-id
  ROBLOX_STORYBOOK_PLACE_ID     Fallback for --place-id
  ROBLOX_CREATOR_USER_ID     Roblox creator user ID (derived from universe if not set)
  GITHUB_TOKEN               GitHub token (enables runtime upgrade checks when set)
  GITHUB_REPOSITORY          GitHub repository, e.g. owner/repo (required with GITHUB_TOKEN)

FLAGS:
  --help                     Show this help message
]])
end

local function run(args: { string })
	local parser = cli.parser()

	parser:add("pr", "option", { help = "PR number" })
	parser:add("universe-id", "option", { help = "Roblox Universe ID" })
	parser:add("place-id", "option", { help = "Roblox Place ID" })
	parser:add("help", "flag")

	parser:parse(args)

	if parser:has("help") then
		help()
		process.exit(0)
	end

	local prNumber = assert(tonumber(parser:get("pr")), "--pr must be a number")

	local universeId = parser:get("universe-id") or process.env.ROBLOX_STORYBOOK_UNIVERSE_ID
	assert(universeId, "universe-id must be provided via --universe-id or ROBLOX_STORYBOOK_UNIVERSE_ID env var")

	local placeId = parser:get("place-id") or process.env.ROBLOX_STORYBOOK_PLACE_ID
	assert(placeId, "place-id must be provided via --place-id or ROBLOX_STORYBOOK_PLACE_ID env var")

	local apiKey = assert(process.env.ROBLOX_API_KEY, "ROBLOX_API_KEY environment variable is required")

	deploy({
		prNumber = prNumber,
		universeId = universeId,
		placeId = placeId,
		apiKey = apiKey,
		creatorUserId = process.env.ROBLOX_CREATOR_USER_ID,
		githubToken = process.env.GITHUB_TOKEN,
		repo = process.env.GITHUB_REPOSITORY,
	})
end

return { run = run }
