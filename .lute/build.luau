local fs = require("@std/fs")
local luau = require("@std/luau")
local path = require("@std/path")
local process = require("@std/process")
local project = require("@repo/project")
local system = require("@lute/system")

local STAGE_PATH = path.join(project.BUILD_PATH, "stage")
local STORE_PREFIX = "~/.loom/store/"

-- Files from the checkout that `cli.luau` requires, copied into the staging
-- folder alongside the dependencies.
local SOURCES = { "cli.luau", "src" }

local function copyInto(src: path.Pathlike, dest: path.Pathlike)
	if fs.type(src) ~= "dir" then
		fs.copy(src, dest)
		return
	end
	fs.createDirectory(dest, { makeParents = true })
	for _, entry in fs.listDirectory(src) do
		copyInto(path.join(src, entry.name), path.join(dest, entry.name))
	end
end

-- `lute compile` stores each bundled file by its path under the deepest folder
-- that all of them share, and the binary looks up a `~/` alias like
-- `~/.loom/store/x` at `.loom/store/x` under that folder. So the binary finds
-- the Loom store only when that folder is the home folder. A checkout outside
-- the home folder pulls it up to the drive root, or to nothing when the
-- checkout and the store are on different drives.
--
-- To keep every bundled file under one folder, this copies the sources into a
-- staging folder inside `build/`, along with each dependency whose alias in the
-- committed `.config.luau` points into the Loom store. The staged
-- `.config.luau` points those aliases at the copies and keeps every other
-- alias as it is. `@std` and `@lute` are built into Lute, so nothing is bundled
-- from their typedefs.
local function stage()
	if fs.exists(STAGE_PATH) then
		fs.removeDirectory(STAGE_PATH, { recursive = true })
	end
	fs.createDirectory(STAGE_PATH, { makeParents = true })

	for _, source in SOURCES do
		copyInto(source, path.join(STAGE_PATH, source))
	end

	local config = luau.loadModule(".config.luau")
	local lines = {}
	for alias, value in config.luau.aliases do
		if value:sub(1, #STORE_PREFIX) == STORE_PREFIX then
			local storePath = path.join(process.homedir(), (value:gsub("^~/", "")))
			copyInto(storePath, path.join(STAGE_PATH, "packages", alias))
			value = `./packages/{alias}`
		end
		local key = if alias:match("^[%a_][%w_]*$") then alias else `["{alias}"]`
		table.insert(lines, `\t\t\t{key} = "{value}",`)
	end
	table.sort(lines)

	local contents = table.concat({
		"return {",
		"\tluau = {",
		`\t\tlanguagemode = "{config.luau.languagemode}",`,
		"\t\taliases = {",
		table.concat(lines, "\n"),
		"\t\t},",
		"\t},",
		"}",
		"",
	}, "\n")
	fs.writeStringToFile(path.join(STAGE_PATH, ".config.luau"), contents)
end

local outputPath = tostring(project.BUILD_OUTPUT)
if string.lower(system.os) == "windows_nt" then
	outputPath = outputPath .. ".exe"
end

if fs.exists(outputPath) then
	fs.remove(outputPath)
end

stage()

local result = process.run({
	"lute",
	"compile",
	"cli.luau",
	"--output",
	outputPath,
	"--bundle-stats",
	"--show-require-graph",
}, {
	cwd = tostring(STAGE_PATH),
	stdio = "inherit",
})
assert(result.ok, "lute compile failed")
