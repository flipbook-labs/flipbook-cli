local fs = require("@std/fs")
local path = require("@std/path")

-- Only the first `version = "..."` line is the package version; dependencies in
-- loom.config.luau are pinned with `rev`, not `version`.
local VERSION_PATTERN = 'version = "[^"]+"'

-- Rewrite the package version in loom.config.luau to `next`.
local function writeVersion(next: string): ()
	local file = tostring(path.resolve("loom.config.luau"))
	local content = fs.readFileToString(file)
	local updated, replacements = content:gsub(VERSION_PATTERN, `version = "{next}"`, 1)
	assert(replacements == 1, `Failed to bump version to {next}`)
	fs.writeStringToFile(file, updated)
end

return writeVersion
