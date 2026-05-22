local cli = require("@batteries/cli")
local process = require("@std/process")

local deploy = require("@root/deploy")
local helpText = require("@root/cli/helpText")

local help: helpText.HelpConfig = {
	title = "deploy",
	summary = "Deploy an rbxm file containing your storybooks and stories to an experience for previewing.",
	env = {
		{
			title = "ENV VARS (required for publish)",
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
					name = "ROBLOX_STORYBOOK_START_PLACE_ID",
					description = "Root place ID (main deploy target; template for new PR places)",
				},
			},
		},
	},
}

local function run(args: { string })
	local parser = cli.parser()

	parser:add("name", "option", {
		help = "Place name. Use pr-<number> for PR previews.",
		default = "main",
	})
	parser:add("stories", "option", {
		help = "Optional .rbxm (or directory) mounted as ReplicatedStorage.Stories",
	})
	parser:add("flipbook-rbxm", "option", {
		help = "Prebuilt Flipbook.rbxm (skips GitHub download)",
	})
	parser:add("dry-run", "option", {
		help = "Build .rbxl locally only (skip Open Cloud publish)",
	})
	parser:add("help", "flag", {
		help = "Show this help message",
	})

	parser:parse(args)

	if parser:has("help") then
		helpText.print(parser, help)
		process.exit(0)
	end

	deploy({
		name = parser:get("name") or "main",
		storiesPath = parser:get("stories"),
		flipbookRbxmPath = parser:get("flipbook-rbxm"),
		dryRun = parser:get("dry-run"),
	})
end

return {
	run = run,
	help = help,
}
