local fs = require("@std/fs")
local path = require("@std/path")

-- Only the first `version = "..."` line is the package version; dependencies in
-- loom.config.luau are pinned with `rev`, not `version`.
local VERSION_PATTERN = 'version = "[^"]+"'

-- Rewrite the package version in loom.config.luau to `nextVersion`.
local function writeVersion(nextVersion: string): ()
	local file = path.resolve("loom.config.luau")
	local content = fs.readFileToString(file)
	local updated, replacements = content:gsub(VERSION_PATTERN, `version = "{nextVersion}"`, 1)
	assert(replacements == 1, `Failed to bump version to {nextVersion}`)
	fs.writeStringToFile(file, updated)
end

return writeVersion
