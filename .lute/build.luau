local fs = require("@std/fs")
local luau = require("@std/luau")
local path = require("@std/path")
local process = require("@std/process")
local project = require("@repo/project")
local system = require("@lute/system")

local STAGE_PATH = path.join(project.BUILD_PATH, "stage")
local STAGED_STORE_PATH = path.join(STAGE_PATH, "store")
local STORE_PATH = path.join(process.homedir(), ".loom", "store")
local CONFIG_FILES = { [".luaurc"] = true, [".config.luau"] = true }

type Lockfile = {
	packages: { [string]: { installPath: string } },
}

-- Copies a folder with `fs` rather than `cp`, which Windows lacks.
-- `storeFromHere` is the relative path from `dest` to the staged store, and
-- each config file copied along the way has its aliases into `~/.loom/store`
-- rewritten to it, so they resolve inside the bundle.
local function copyInto(src: path.Pathlike, dest: path.Pathlike, storeFromHere: string)
	fs.createDirectory(dest, { makeParents = true })
	for _, entry in fs.listDirectory(src) do
		local from, to = path.join(src, entry.name), path.join(dest, entry.name)
		if entry.type == "dir" then
			copyInto(from, to, `../{storeFromHere}`)
		elseif CONFIG_FILES[entry.name] then
			local config = fs.readFileToString(from):gsub("~/%.loom/store", storeFromHere)
			fs.writeStringToFile(to, config)
		else
			fs.copy(from, to)
		end
	end
end

-- `lute compile` stores each bundled file by its path under the deepest folder
-- that all of them share, and the binary looks up a `~/` alias like
-- `~/.loom/store/x` at `.loom/store/x` under that folder. So a binary bundled
-- straight from the Loom store finds its dependencies only when that folder is
-- the home folder, which fails for a checkout outside it.
--
-- To keep every bundled file under one folder, this copies the sources into a
-- staging folder inside `build/`, and each store folder in the lockfile into
-- `store/` beside them. Every `.config.luau` and `.luaurc` in the copy, the
-- root one included, points its store aliases at that `store/` folder instead.
-- `@std` and `@lute` are built into Lute, so nothing is bundled from their
-- typedefs.
local function stage()
	if fs.exists(STAGE_PATH) then
		fs.removeDirectory(STAGE_PATH, { recursive = true })
	end
	fs.createDirectory(STAGE_PATH, { makeParents = true })

	local config = fs.readFileToString(".config.luau"):gsub("~/%.loom/store", "./store")
	fs.writeStringToFile(path.join(STAGE_PATH, ".config.luau"), config)
	fs.copy("cli.luau", path.join(STAGE_PATH, "cli.luau"))
	copyInto("src", path.join(STAGE_PATH, "src"), "../store")

	-- The lockfile writes `@pkg/` for the store. Dependencies from the same
	-- repository, like Lute's batteries, share a store folder.
	local lockfile: Lockfile = luau.loadModule("pkg.lock.luau")
	for _, package in lockfile.packages do
		local folder = package.installPath:match("^@pkg/([^/]+)")
		assert(folder, `Unexpected install path {package.installPath}`)
		local dest = path.join(STAGED_STORE_PATH, folder)
		if not fs.exists(dest) then
			copyInto(path.join(STORE_PATH, folder), dest, "..")
		end
	end
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

-- A binary missing a package still compiles but fails on its first require, so
-- running it once here catches that before anything ships it.
local smoke = process.run({ outputPath, "--help" })
assert(smoke.ok, `{outputPath} failed to start: {smoke.stderr}`)
