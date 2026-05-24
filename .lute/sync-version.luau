local args = { ... }

local nextVersion = args[2] or args[1]
if type(nextVersion) ~= "string" or nextVersion == "" then
	error("expected version argument, e.g. lute run sync-version 0.1.1")
end

local fs = require("@std/fs")
local path = require("@std/path")

local configPath = path.resolve("loom.config.luau")
local configFile = fs.open(configPath, "r")
if configFile == nil then
	error("failed to open loom.config.luau")
end

local content = fs.read(configFile)
fs.close(configFile)

local updated, replacements = string.gsub(content, 'version = "[^"]+"', string.format('version = "%s"', nextVersion), 1)
if replacements ~= 1 then
	error("failed to update version in loom.config.luau")
end

local outputFile = fs.open(configPath, "w+")
if outputFile == nil then
	error("failed to open loom.config.luau for writing")
end
fs.write(outputFile, updated)
fs.close(outputFile)
