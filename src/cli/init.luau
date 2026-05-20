local dotenv = require("@pkg/dotenv@v0.1.0/src")

local commands = require("@self/commands")

-- Scan args for the first positional value (skip --option <value> pairs and -flags).
-- Needed because lute prepends --universe-id and --place-id before the subcommand.
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

local function help()
	print([[
flipbook-cli
Deploy Flipbook storybooks to Roblox Open Cloud for pull request previews.

USAGE:
  flipbook-cli <command> [options]

COMMANDS:
  deploy   Build and deploy a storybook for a pull request.
  prune    Remove the storybook for a closed or merged pull request.
  comment  Post or update the storybook preview comment on a pull request.
  help     Show this help message.

For more information about a command, run: flipbook-cli <command> --help
]])
end

local availableCommands = {
	deploy = commands.deploy,
	prune = commands.prune,
	comment = commands.comment,
	help = { run = help },
}

local function run(args: { string })
	dotenv.config()

	local subcommand = findSubcommand(args)
	local command = availableCommands[subcommand] or availableCommands.help
	command.run(args)
end

return { run = run }
