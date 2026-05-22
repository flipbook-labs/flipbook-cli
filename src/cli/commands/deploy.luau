local cli = require("@batteries/cli")
local process = require("@std/process")

local constants = require("@root/constants")
local deploy = require("@root/deploy")
local resolveRobloxApiKey = require("@root/resolveRobloxApiKey")

local function help()
	print([[
flipbook-cli deploy
Build and publish a storybook place (Open Cloud).

USAGE:
  flipbook-cli deploy [options]

OPTIONS:
  --name <name>              Place name (default: main). Use pr-<number> for PR previews.
  --stories <path>           Optional .rbxm (or directory) mounted as ReplicatedStorage.Stories
  --universe-id <id>         Universe ID of the experience to publish to
  --place-id <id>            Root place ID (required for publish)
  --api-key, -k <key>        Roblox Open Cloud API key (default: ROBLOX_API_KEY)
  --flipbook-rbxm <path>     Prebuilt Flipbook.rbxm (skips GitHub download)
  --dry-run <path>           Build .rbxl locally only (skip Open Cloud publish)
  --help                     Show this help message

ENV VARS:
  ROBLOX_API_KEY             Roblox Open Cloud API key (when --api-key is not passed)

OPTIONAL ENV VARS:
  GITHUB_TOKEN               Avoids GitHub API rate limits when downloading Flipbook.rbxm
]])
end

local function run(args: { string })
	local parser = cli.parser()

	parser:add("stories", "option", {
		help = "Stories .rbxm or directory",
		required = true,
	})
	parser:add("universe-id", "option", {
		help = "Universe ID of the experience to publish to",
		required = true,
	})
	parser:add("place-id", "option", {
		help = "Root place ID",
	})
	parser:add("api-key", "option", {
		aliases = { "k" },
		help = "Roblox Open Cloud API key (default: ROBLOX_API_KEY)",
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

	local dryRun = parser:get("dry-run")
	local universeId = parser:get("universe-id")
	local placeId = parser:get("place-id")
	local apiKey: string? = nil

	if not dryRun then
		assert(universeId, "--universe-id is required")
		assert(placeId, "--place-id is required")
		apiKey = resolveRobloxApiKey(parser:get("api-key"))
	end

	deploy({
		name = parser:get("name") or constants.MAIN_PLACE_NAME,
		storiesPath = parser:get("stories"),
		universeId = universeId,
		placeId = placeId,
		apiKey = apiKey,
		flipbookRbxmPath = parser:get("flipbook-rbxm"),
		dryRun = dryRun,
	})
end

return { run = run }
