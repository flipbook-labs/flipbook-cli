local cli = require("@batteries/cli")

local getCurrentVersion = require("@root/release/getCurrentVersion")
local renderReleaseNotes = require("@root/release/renderReleaseNotes")
local types = require("@root/cli/types")

local title = "release notes"
local summary = "Print the Markdown notes for a version (the body of its GitHub release)."

local parser = cli.parser()
parser:add("version", "option", {
	help = "Version to render notes for. Defaults to the version in loom.config.luau.",
})
parser:add("help", "flag", {
	help = "Show this help message",
})

local function notes()
	local version = parser:get("version") or getCurrentVersion()
	print(renderReleaseNotes(`v{version}`))
end

local command: types.Command = {
	run = notes,
	title = title,
	summary = summary,
	parser = parser,
}

return command
