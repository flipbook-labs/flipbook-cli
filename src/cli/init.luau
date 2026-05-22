local dotenv = require("@pkg/dotenv@v0.1.0/src")

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
Deploy Flipbook storybook experiences via Open Cloud.

USAGE:
  flipbook-cli <command> [options]

COMMANDS:
  deploy   Build and publish a storybook place
  comment  Post or update a PR preview comment
  yank     Publish an empty place to clear a PR preview
  help     Show this help message

For more information: flipbook-cli <command> --help
]])
end

local availableCommands = {
	deploy = require("@self/commands/deploy"),
	yank = require("@self/commands/yank"),
	comment = require("@self/commands/comment"),
	help = { run = help },
}

local function run(args: { string })
	dotenv.config()

	local subcommand = findSubcommand(args)
	local command = availableCommands[subcommand] or availableCommands.help
	command.run(args)
end

return { run = run }
