local cli = require("@batteries/cli")
local args = { ... }

local fs = require("@std/fs")
local path = require("@std/path")

local parser = cli.parser()
parser:add("version", "option", {
	help = "Semver-compatible version string used as the next release number",
	required = true,
})
parser:parse(args)

local nextVersion = parser:get("version") :: string

local configPath = path.resolve("loom.config.luau")
local content = fs.readFileToString(configPath)

local updated, replacements = content:gsub('(\t\tversion = ")[^"]+(")', "%1" .. nextVersion .. "%2", 1)
if replacements ~= 1 then
	error("failed to update package version")
end

fs.writeStringToFile(configPath, updated)
