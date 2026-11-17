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
	dependencies: { [string]: string },
	packages: { [string]: { installPath: string, dependencies: { [string]: string } } },
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

	-- Only `dependencies` and what they depend on are staged, since dev
	-- dependencies never reach the binary. The lockfile writes `@pkg/` for the
	-- store, and the path of a dependency without a `target` ends in `/.`. A
	-- dependency with a `target`, like Lute's `batteries`, stages only that
	-- subfolder. Both keep staged paths short, since a whole repository or the
	-- skills library holds paths deep enough to pass Windows' 260-character
	-- limit.
	local lockfile: Lockfile = luau.loadModule("pkg.lock.luau")
	local function stagePackage(key: string)
		local package = lockfile.packages[key]
		local relative = package.installPath:gsub("^@pkg/", ""):gsub("/%.$", "")
		local dest = path.join(STAGED_STORE_PATH, relative)
		if fs.exists(dest) then
			return
		end
		local _, depth = relative:gsub("/", "")
		copyInto(path.join(STORE_PATH, relative), dest, string.rep("../", depth) .. "..")
		for _, dependency in package.dependencies do
			stagePackage(dependency)
		end
	end
	for _, key in lockfile.dependencies do
		stagePackage(key)
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
