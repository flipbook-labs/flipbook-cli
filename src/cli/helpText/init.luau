local cli = require("@batteries/cli")

local format = require("@self/format")
local root = require("@self/root")

local PROGRAM_NAME = "flipbook-cli"

export type EnvVar = {
	name: string,
	description: string,
	required: boolean?,
}

export type EnvGroup = {
	title: string?,
	vars: { EnvVar },
}

export type HelpSection = {
	heading: string,
	lines: { string },
}

export type HelpConfig = {
	title: string,
	summary: string?,
	usage: string?,
	env: { EnvGroup }?,
	sections: { HelpSection }?,
	skipFlags: { string }?,
}

type ArgData = {
	name: string,
	kind: string,
	options: {
		help: string?,
		aliases: { string }?,
		default: string?,
		required: boolean?,
		hidden: boolean?,
	},
}

local function collectArgLines(parser: cli.Parser, config: HelpConfig): ({ string }, { string })
	local requiredLines: { string } = {}
	local optionLines: { string } = {}
	local skipFlags = config.skipFlags

	for _, argument in parser.arguments :: { ArgData } do
		if argument.options.hidden then
			continue
		end
		if format.shouldSkip(argument.name, skipFlags) then
			continue
		end
		if argument.kind == "positional" or argument.kind == "variadic" then
			continue
		end

		local line = format.formatArgLine(argument.name, argument.kind, argument.options)
		if argument.options.required then
			table.insert(requiredLines, line)
		else
			table.insert(optionLines, line)
		end
	end

	return requiredLines, optionLines
end

local function appendEnvGroups(lines: { string }, envGroups: { EnvGroup })
	for _, group in envGroups do
		local heading = group.title or "ENV VARS"
		local envLines: { string } = {}
		for _, envVar in group.vars do
			local padding = math.max(1, 32 - #envVar.name)
			local suffix = if envVar.required then " (required)" else ""
			table.insert(envLines, `  {envVar.name}{string.rep(" ", padding)}{envVar.description}{suffix}`)
		end
		format.appendSection(lines, heading, envLines)
	end
end

local function build(parser: cli.Parser, config: HelpConfig): string
	local title = `{PROGRAM_NAME} {config.title}`
	local lines: { string } = { title }

	if config.summary then
		table.insert(lines, config.summary)
	end

	table.insert(lines, "")
	table.insert(lines, "USAGE:")
	table.insert(lines, `  {config.usage or parser:usage(title)}`)
	table.insert(lines, "")

	local requiredLines, optionLines = collectArgLines(parser, config)

	if #requiredLines > 0 then
		format.appendSection(lines, "REQUIRED", requiredLines)
	end

	if #optionLines > 0 then
		format.appendSection(lines, "OPTIONS", optionLines)
	end

	if config.env then
		appendEnvGroups(lines, config.env)
	end

	if config.sections then
		for _, section in config.sections do
			format.appendSection(lines, section.heading, section.lines)
		end
	end

	-- Trim trailing blank line from last appendSection
	if lines[#lines] == "" then
		table.remove(lines, #lines)
	end

	return table.concat(lines, "\n")
end

local function printHelp(parser: cli.Parser, config: HelpConfig): ()
	print(build(parser, config))
end

return {
	build = build,
	print = printHelp,
	buildRoot = root.buildRoot,
	printRoot = root.printRoot,
}
