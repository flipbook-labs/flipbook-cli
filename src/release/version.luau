local fs = require("@std/fs")
local path = require("@std/path")

-- Only the first `version = "..."` line is the package version; dependencies in
-- loom.config.luau are pinned with `rev`, not `version`.
local VERSION_PATTERN = 'version = "[^"]+"'

export type BumpKind = "minor" | "patch"

local function parse(version: string): (number, number, number)
	local major, minor, patch = string.match(version, "^(%d+)%.(%d+)%.(%d+)$")
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

local function configPath(): string
	return tostring(path.resolve("loom.config.luau"))
end

local function read(): string
	local content = fs.readFileToString(configPath())
	local version = string.match(content, 'version = "([^"]+)"')
	assert(version, "Could not read package version from loom.config.luau")
	return version :: string
end

local function write(next: string): ()
	local file = configPath()
	local content = fs.readFileToString(file)
	local updated, replacements = string.gsub(content, VERSION_PATTERN, `version = "{next}"`, 1)
	assert(replacements == 1, `Failed to bump version to {next}`)
	fs.writeStringToFile(file, updated)
end

return {
	parse = parse,
	bump = bump,
	read = read,
	write = write,
}
