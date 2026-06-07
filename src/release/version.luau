local fs = require("@std/fs")
local path = require("@std/path")

local loomConfig = require("@repo/loom.config")

-- Only the first `version = "..."` line is the package version; dependencies in
-- loom.config.luau are pinned with `rev`, not `version`.
local VERSION_PATTERN = 'version = "[^"]+"'

export type BumpKind = "minor" | "patch"

local function parse(version: string): (number, number, number)
	local major, minor, patch = version:match("^(%d+)%.(%d+)%.(%d+)$")
	assert(major and minor and patch, `Invalid semver version: "{version}"`)
	return tonumber(major) :: number, tonumber(minor) :: number, tonumber(patch) :: number
end

-- Compute the next version. `minor` resets the patch (x.y.z -> x.(y+1).0);
-- `patch` increments the patch (x.y.z -> x.y.(z+1)).
local function bump(version: string, kind: BumpKind): string
	local major, minor, patch = parse(version)
	if kind == "patch" then
		return `{major}.{minor}.{patch + 1}`
	end
	return `{major}.{minor + 1}.0`
end

local function read(): string
	return loomConfig.package.version
end

local function write(next: string): ()
	local file = tostring(path.resolve("loom.config.luau"))
	local content = fs.readFileToString(file)
	local updated, replacements = content:gsub(VERSION_PATTERN, `version = "{next}"`, 1)
	assert(replacements == 1, `Failed to bump version to {next}`)
	fs.writeStringToFile(file, updated)
end

return {
	parse = parse,
	bump = bump,
	read = read,
	write = write,
}
