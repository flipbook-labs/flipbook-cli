local cli = require("@batteries/cli")
local process = require("@std/process")

local resolveRobloxApiKey = require("@root/resolveRobloxApiKey")
local yank = require("@root/yank")

local function help()
	print([[
flipbook-cli yank
Publish an empty place to clear a PR preview (Roblox places cannot be deleted).

USAGE:
  flipbook-cli yank [options]

OPTIONS:
  --name <name>              Place name to clear (e.g. pr-42)
  --universe-id <id>         Experience (universe) ID
  --place-id <id>            Root place ID (Luau Execution host)
  --api-key, -k <key>        Roblox API key (default: ROBLOX_API_KEY)
  --help                     Show this help message

ENV VARS:
  ROBLOX_API_KEY             Roblox API key (when --api-key is not passed)
]])
end

local function run(args: { string })
	local parser = cli.parser()

	parser:add("name", "option", {
		help = "Place name",
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

	local name = parser:get("name")
	assert(name, "--name is required")

	yank({
		name = name,
		universeId = parser:get("universe-id"),
		placeId = parser:get("place-id"),
		apiKey = resolveRobloxApiKey(parser:get("api-key")),
	})
end

return { run = run }
