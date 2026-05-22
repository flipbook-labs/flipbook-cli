local cli = require("@batteries/cli")
local process = require("@std/process")

local yank = require("@root/yank")
local helpText = require("@root/cli/helpText")

local DESCRIPTION = "Publish an empty place to clear a PR preview"

local HELP: helpText.HelpConfig = {
	title = "yank",
	summary = "Publish an empty place to clear a PR preview (Roblox places cannot be deleted).",
	env = {
		{
			vars = {
				{ name = "ROBLOX_API_KEY", description = "Roblox API key", required = true },
				{ name = "ROBLOX_STORYBOOK_UNIVERSE_ID", description = "Experience (universe) ID" },
				{ name = "ROBLOX_STORYBOOK_PLACE_ID", description = "Root place ID (Luau Execution host)" },
			},
		},
	},
}

local function run(args: { string })
	local parser = cli.parser()

	parser:add("name", "option", {
		help = "Place name to clear (e.g. pr-42)",
		required = true,
	})
	parser:add("universe-id", "option", {
		help = "Experience (universe) ID. Defaults to ROBLOX_STORYBOOK_UNIVERSE_ID if set.",
	})
	parser:add("place-id", "option", {
		help = "Root place ID. Defaults to ROBLOX_STORYBOOK_PLACE_ID if set.",
	})
	parser:add("help", "flag", {
		help = "Show this help message",
	})

	parser:parse(args)

	if parser:has("help") then
		helpText.print(parser, HELP)
		process.exit(0)
	end

	local name = parser:get("name")
	assert(name, "--name is required")

	yank({
		name = name,
		universeId = parser:get("universe-id"),
		placeId = parser:get("place-id"),
	})
end

return {
	run = run,
	description = DESCRIPTION,
}
