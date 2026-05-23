local process = require("@std/process")
local richterm = require("@batteries/richterm")

local helpText = require("@self/helpText")
local types = require("@self/types")

local commentCommand = require("@self/commands/comment")
local deployCommand = require("@self/commands/deploy")
local helpCommand = require("@self/commands/help")
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

local availableCommands: { [string]: types.Command } = {
	deploy = deployCommand,
	comment = commentCommand,
	yank = yankCommand,
	help = helpCommand,
}

local function run(args: { string })
	local subcommand = findSubcommand(args)
	local command: types.Command = (subcommand and availableCommands[subcommand]) or availableCommands.help

	if command.parser then
		command.parser:parse(args)
		if command.parser:has("help") then
			helpText.print(command.parser, {
				title = command.title,
				summary = command.summary,
			})
			process.exit(0)
		end
	end

	local ok, err = pcall(command.run, args)
	if not ok then
		local message = tostring(err):match(":%d+: (.+)$") or tostring(err)
		print(richterm.red("Error: " .. message))
		print()
		if command.parser then
			helpText.print(command.parser, { title = command.title, summary = command.summary })
		else
			helpCommand.run(args)
		end
		process.exit(1)
	end
end

return {
	run = run,
}
