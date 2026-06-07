local fs = require("@std/fs")
local path = require("@std/path")

-- Only the first `version = "..."` line is the package version; dependencies in
-- loom.config.luau are pinned with `rev`, not `version`.
local VERSION_PATTERN = 'version = "([^"]+)"'

-- Read the package version from the loom.config.luau in the current directory.
-- We resolve and read it ourselves rather than `require`ing it, since a require
-- always binds to flipbook-cli's own config instead of the repo being released.
local function getCurrentVersion(): string
	local file = tostring(path.resolve("loom.config.luau"))
	local content = fs.readFileToString(file)
	local version = content:match(VERSION_PATTERN)
	assert(version, `Could not find a package version in {file}`)
	return version
end

return getCurrentVersion
