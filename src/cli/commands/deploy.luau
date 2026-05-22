local cli = require("@batteries/cli")
local process = require("@std/process")

local constants = require("@root/constants")
local deploy = require("@root/deploy")

local function help()
	print([[
flipbook-cli deploy
Build and publish a storybook place (Open Cloud).

USAGE:
  flipbook-cli deploy [options]

OPTIONS:
  --name <name>              Place name (default: main). Use pr-<number> for PR previews.
  --stories <path>           Optional .rbxm (or directory) mounted as ReplicatedStorage.Stories
  --universe-id <id>         Experience (universe) ID. Defaults to ROBLOX_STORYBOOK_UNIVERSE_ID if it exists.
  --place-id <id>            Root place ID. Defaults to ROBLOX_STORYBOOK_PLACE_ID if it exists.
  --flipbook-rbxm <path>     Prebuilt Flipbook.rbxm (skips GitHub download)
  --dry-run <path>           Build .rbxl locally only (skip Open Cloud publish)
  --help                     Show this help message

ENV VARS (required for publish):
  ROBLOX_API_KEY                  Roblox Open Cloud API key
  ROBLOX_STORYBOOK_UNIVERSE_ID    Experience (universe) ID
  ROBLOX_STORYBOOK_PLACE_ID       Root place ID (main deploy target; template for new PR places)

OPTIONAL ENV VARS:
  GITHUB_TOKEN                    Avoids GitHub API rate limits in CI
]])
end

local function run(args: { string })
	local parser = cli.parser()

	parser:add("name", "option", {
		help = "Place name",
		default = constants.MAIN_PLACE_NAME,
	})
	parser:add("stories", "option", {
		help = "Stories .rbxm or directory",
	})
	parser:add("universe-id", "option", {
		help = "Experience (universe) ID",
		required = true,
	})
	parser:add("place-id", "option", {
		help = "Root place ID",
	})
	parser:add("flipbook-rbxm", "option", {
		help = "Path to Flipbook.rbxm",
	})
	parser:add("dry-run", "option", {
		help = "Output .rbxl path without publishing",
	})
	parser:add("help", "flag", {
		help = "Shows this help message",
	})

	parser:parse(args)

	if parser:has("help") then
		help()
		process.exit(0)
	end

	deploy({
		name = parser:get("name") or constants.MAIN_PLACE_NAME,
		storiesPath = parser:get("stories"),
		universeId = parser:get("universe-id"),
		placeId = parser:get("place-id"),
		flipbookRbxmPath = parser:get("flipbook-rbxm"),
		dryRun = parser:get("dry-run"),
	})
end

return {
	run = run,
	help = help,
}
