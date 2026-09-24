local cli = require("@batteries/cli")
local process = require("@std/process")
local richterm = require("@batteries/richterm")

local commentCommand = require("@self/commands/comment")
local deployCommand = require("@self/commands/deploy")
local types = require("@self/types")

local PROGRAM_NAME = "flipbook-cli"
local SUMMARY = "Deploy Flipbook storybook experiences via Open Cloud."
local HELP_SUMMARY = "Show this help message"

local availableCommands: { { name: string, command: types.Command } } = {
	{
		name = "deploy",
		command = deployCommand,
	},
	{
		name = "comment",
		command = commentCommand,
	},
}

local function createParser(): cli.Parser
	local parser = cli.parser()
	parser:add("help", "flag", {
		help = HELP_SUMMARY,
	})

	for _, entry in availableCommands do
		entry.command.configure(parser:subcommand(entry.name, {
			help = entry.command.summary,
		}))
	end
	parser:subcommand("help", {
		help = HELP_SUMMARY,
	})

	return parser
end

local function findCommand(name: string?): types.Command?
	for _, entry in availableCommands do
		if entry.name == name then
			return entry.command
		end
	end
	return nil
end

local function printHelp(parser: cli.Parser, title: string, summary: string)
	print(`{title}\n{summary}\n\n{parser:usage(title)}\n\n{parser:help()}`)
end

-- Lute passes the program path as the first argument.
local function run(args: { string })
	local parser = createParser()
	local ok, err = pcall(parser.parse, parser, table.move(args, 2, #args, 1, {}))

	local name, commandParser = parser:selected()
	local command = findCommand(name)

	local function printSelectedHelp()
		if command and commandParser then
			printHelp(commandParser, `{PROGRAM_NAME} {name}`, command.summary)
		else
			printHelp(parser, PROGRAM_NAME, SUMMARY)
		end
	end

	if not ok then
		local message = tostring(err):match(":%d+: (.+)$") or tostring(err)
		print(richterm.red("Error: " .. message))
		print()
		printSelectedHelp()
		process.exit(1)
	end

	if not command or not commandParser or parser:has("help") or commandParser:has("help") then
		printSelectedHelp()
		return
	end

	command.run(commandParser)
end

return {
	run = run,
}
