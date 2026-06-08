local helpText = require("@root/cli/helpText")
local types = require("@root/cli/types")

local commentCommand = require("@root/cli/commands/comment")
local deployCommand = require("@root/cli/commands/deploy")
local releaseCommand = require("@root/cli/commands/release")

local title = "help"
local summary = "Show this help message"

local function run()
	helpText.printRoot({
		title = "flipbook-cli",
		summary = "Deploy Flipbook storybook experiences via Open Cloud.",
		commands = {
			{
				name = "deploy",
				description = deployCommand.summary,
			},
			{
				name = "comment",
				description = commentCommand.summary,
			},
			{
				name = "release",
				description = releaseCommand.summary,
			},
			{
				name = "help",
				description = summary,
			},
		},
	})
end

local command: types.Command = {
	run = run,
	title = title,
	summary = summary,
}

return command
