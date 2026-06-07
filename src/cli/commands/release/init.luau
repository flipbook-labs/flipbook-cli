local process = require("@std/process")
local richterm = require("@batteries/richterm")

local helpText = require("@root/cli/helpText")
local types = require("@root/cli/types")

local attachCommand = require("@self/attach")
local gateCommand = require("@self/gate")
local preparePrCommand = require("@self/preparePr")
local publishCommand = require("@self/publish")

local title = "release"
local summary = "Manage the release lifecycle (gate, publish, attach, prepare-pr)."

local subcommands: { [string]: types.Command } = {
	gate = gateCommand,
	publish = publishCommand,
	attach = attachCommand,
	["prepare-pr"] = preparePrCommand,
}

-- Display order for the help listing.
local ORDER = { "gate", "publish", "attach", "prepare-pr" }

local function printRootHelp(): ()
	local commands: { { name: string, description: string } } = {}
	for _, name in ORDER do
		table.insert(commands, { name = name, description = subcommands[name].summary })
	end
	helpText.printRoot({
		title = `flipbook-cli {title}`,
		summary = summary,
		commands = commands,
		footer = `For more information: flipbook-cli {title} <command> --help`,
	})
end

-- Find the word following `release` (the nested subcommand) and its index. We
-- only need a simple scan: nothing precedes `release <subcommand>` that consumes
-- a value, so any token that isn't a flag and isn't `release` itself is it.
local function findSubcommand(args: { string }): (string?, number?)
	local seenRelease = false
	for i, arg in args do
		if string.sub(arg, 1, 1) == "-" then
			continue
		elseif seenRelease then
			return arg, i
		elseif arg == "release" then
			seenRelease = true
		end
	end
	return nil, nil
end

local function run(args: { string })
	local subName, index = findSubcommand(args)

	if not subName or subName == "help" then
		printRootHelp()
		return
	end

	local command = subcommands[subName]
	if not command then
		print(richterm.red(`Error: unknown release subcommand "{subName}"`))
		print()
		printRootHelp()
		process.exit(1)
	end

	-- Hand the subcommand only the args after its name so its parser sees a clean
	-- argument list (and variadics aren't polluted by `release`/the name itself).
	local subArgs = table.move(args, (index :: number) + 1, #args, 1, {})

	local parser = command.parser
	if parser then
		local ok, err = pcall(parser.parse, parser, subArgs)
		if not ok then
			local message = tostring(err):match(":%d+: (.+)$") or tostring(err)
			print(richterm.red("Error: " .. message))
			print()
			helpText.print(parser, { title = command.title, summary = command.summary })
			process.exit(1)
		end

		if parser:has("help") then
			helpText.print(parser, { title = command.title, summary = command.summary })
			process.exit(0)
		end
	end

	command.run(subArgs)
end

local command: types.Command = {
	run = run,
	title = title,
	summary = summary,
}

return command
