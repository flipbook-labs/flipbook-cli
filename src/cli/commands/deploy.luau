local cli = require("@batteries/cli")
local process = require("@std/process")

local deploy = require("@root/deploy")
local helpText = require("@root/cli/helpText")
local types = require("@root/cli/types")

local title = "deploy"
local summary = "Deploy an rbxm file containing your storybooks and stories to an experience for previewing."

local parser = cli.parser()

parser:add("name", "option", {
	help = "Name of the place to update or create for this deployment.",
	required = true,
})
parser:add("api-key", "option", {
	help = "Roblox API key (Can also be supplied by the ROBLOX_API_KEY env var)",
	default = process.env.ROBLOX_API_KEY,
	required = true,
})
parser:add("universe-id", "option", {
	help = "Universe to deploy to.",
	required = true,
})
parser:add("stories", "option", {
	help = "Path to an rbxm file containing storybooks and stories.",
	required = true,
})
parser:add("dry-run", "option", {
	help = "Skip any steps that would make changes to the live Roblox experience.",
})
parser:add("help", "flag", {
	help = "Show this help message",
})

local function run(args: { string })
	parser:parse(args)

	if parser:has("help") then
		helpText.print(parser, { title = title, summary = summary })
		process.exit(0)
	end

	deploy({
		name = parser:get("name") or "main",
		storiesPath = parser:get("stories"),
		dryRun = parser:get("dry-run"),
		apiKey = parser:get("api-key"),
	})
end

local command: types.Command = {
	run = run,
	title = title,
	summary = summary,
	parser = parser,
}

return command
