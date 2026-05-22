local cli = require("@batteries/cli")
local process = require("@std/process")

local yank = require("@root/yank")

local function help()
	print([[
flipbook-cli yank
Publish an empty place to clear a PR preview (Roblox places cannot be deleted).

USAGE:
  flipbook-cli yank [options]

OPTIONS:
  --name <name>              Place name to clear (e.g. pr-42)
  --universe-id <id>         Experience (universe) ID. Overrides ROBLOX_STORYBOOK_UNIVERSE_ID.
  --place-id <id>            Root place ID. Overrides ROBLOX_STORYBOOK_PLACE_ID / ROBLOX_STORYBOOK_PLACE_ID.
  --help                     Show this help message

ENV VARS:
  ROBLOX_API_KEY                  Roblox API key (required)
  ROBLOX_STORYBOOK_UNIVERSE_ID    Experience (universe) ID
  ROBLOX_STORYBOOK_PLACE_ID Root place ID (Luau Execution host)
]])
end

local function run(args: { string })
	local parser = cli.parser()

	parser:add("name", "option", { help = "Place name" })
	parser:add("universe-id", "option", { help = "Experience (universe) ID" })
	parser:add("place-id", "option", { help = "Root place ID" })
	parser:add("help", "flag")

	parser:parse(args)

	if parser:has("help") then
		help()
		process.exit(0)
	end

	local name = parser:get("name")
	assert(name, "--name is required")

	yank({
		name = name,
		universeId = parser:get("universe-id"),
		startPlaceId = parser:get("place-id"),
	})
end

return { run = run }
