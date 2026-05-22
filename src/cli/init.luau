local dotenv = require("@pkg/dotenv@v0.1.0/src")
local process = require("@std/process")
local richterm = require("@batteries/richterm")

local helpText = require("@self/helpText")

local commentCommand = require("@self/commands/comment")
local deployCommand = require("@self/commands/deploy")
local yankCommand = require("@self/commands/yank")

local function findSubcommand(args: { string }): string?
	local i = 2
	while i <= #args do
		local arg = args[i]
		if string.sub(arg, 1, 2) == "--" then
			i += 2
		elseif string.sub(arg, 1, 1) == "-" then
			i += 1
		else
			return arg
		end
	end
	return nil
end

local availableCommands = {
	deploy = deployCommand,
	comment = commentCommand,
	yank = yankCommand,
}

local function help()
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
				name = "yank",
				description = yankCommand.summary,
			},
			{
				name = "help",
				description = "Show this help message",
			},
		},
	})
end

availableCommands.help = { run = help }

local function run(args: { string })
	dotenv.config()

	local subcommand = findSubcommand(args)
	local command = availableCommands[subcommand] or availableCommands.help

	local ok, err = pcall(command.run, args)
	if not ok then
		local message = tostring(err):match(":%d+: (.+)$") or tostring(err)
		print(richterm.red("Error: " .. message))
		print()
		if command.parser then
			helpText.print(command.parser, { title = command.title, summary = command.summary })
		else
			help()
		end
		process.exit(1)
	end
end

return {
	run = run,
}
