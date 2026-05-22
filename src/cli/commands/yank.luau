local cli = require("@batteries/cli")
local process = require("@std/process")

local helpText = require("@root/cli/helpText")
local yank = require("@root/yank")

local help: helpText.HelpConfig = {
	title = "yank",
	summary = "Publish an empty place to clear a PR preview",
	env = {
		{
			vars = {
				{
					name = "ROBLOX_API_KEY",
					description = "Roblox API key",
				},
				{
					name = "ROBLOX_STORYBOOK_UNIVERSE_ID",
					description = "Experience (universe) ID",
				},
				{
					name = "ROBLOX_STORYBOOK_PLACE_ID",
					description = "Root place ID (Luau Execution host)",
				},
			},
		},
	},
}

local function run(args: { string })
	local parser = cli.parser()

	parser:add("universe-id", "option", {
		help = "Universe ID of the experience to deploy to.",
	})
	parser:add("place-id", "option", {
		help = "Optional place ID to publish to.",
	})
	parser:add("help", "flag", {
		help = "Show this help message",
	})

	parser:parse(args)

	if parser:has("help") then
		helpText.print(parser, help)
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
	help = help,
}
