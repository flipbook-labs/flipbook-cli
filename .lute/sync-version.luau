local cli = require("@batteries/cli")
local args = { ... }

local fs = require("@std/fs")
local path = require("@std/path")

local parser = cli.parser()
parser:add("version", "option", {
	help = "Version to write into loom.config.luau",
	required = true,
})
parser:parse(args)

local nextVersion = parser:get("version") :: string

local configPath = path.resolve("loom.config.luau")
local content = fs.readFileToString(configPath)

local updated, replacements = content:gsub('version = "[^"]+"', `version = "{nextVersion}"`, 1)
if replacements ~= 1 then
	error("failed to update version in loom.config.luau")
end

fs.writeStringToFile(configPath, updated)
