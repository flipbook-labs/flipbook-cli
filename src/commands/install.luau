local FlipbookBatteries = require("@pkg/flipbook-batteries@v0.9.0")
local cli = require("@batteries/cli")
local fs = require("@std/fs")
local path = require("@std/path")

local fetchFlipbookRbxm = require("@root/fetchFlipbookRbxm")
local getStudioPluginsPath = require("@root/getStudioPluginsPath")
local types = require("@root/cli/types")

local PLUGIN_FILENAME = "Flipbook.rbxm"

local function ensureParentDirectory(filePath: string)
	local parent = filePath:match("^(.*)/[^/]+$")
	if parent and parent ~= "" then
		fs.createDirectory(parent, { makeParents = true })
	end
end

local title = "install"
local summary = "Download and install the Flipbook plugin to Roblox Studio."

local parser = cli.parser()

parser:add("tag", "option", {
	help = "Release tag to install (e.g. v1.2.3). Defaults to the latest stable release.",
})
parser:add("output", "option", {
	help = "Output path (default: Roblox Studio plugins folder / Flipbook.rbxm)",
})
parser:add("help", "flag", {
	help = "Show this help message",
})

local function run(_args: { string })
	local tag = parser:get("tag")
	local rbxmPath = fetchFlipbookRbxm(if tag then { tag = tag } else nil)

	local dest = parser:get("output")
	if dest == nil then
		dest = tostring(path.join(getStudioPluginsPath(), PLUGIN_FILENAME))
	end

	ensureParentDirectory(dest)

	FlipbookBatteries.copyInto(rbxmPath, dest)

	print(`Installed {PLUGIN_FILENAME} to {dest}`)
end

local command: types.Command = {
	run = run,
	title = title,
	summary = summary,
	parser = parser,
}

return command
