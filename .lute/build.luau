local fs = require("@std/fs")
local path = require("@std/path")
local process = require("@std/process")
local project = require("@repo/project")

local storeDir = path.join(process.homedir(), ".loom/store")
local packagesDir = path.resolve("packages")

if not fs.exists(packagesDir) then
	fs.createDirectory(packagesDir)
end

local lock = require("@repo/loom.lock")

process.run({
	"lute",
	"pkg",
	"install",
}, {
	stdio = "inherit",
})

-- Lute doesn't seem able to bundle `~/.loom/store` yet, so we need to copy the
-- packages into our project directory to allow them to be part of the bundle.
for packageId in lock.packages do
	local src = path.join(storeDir, packageId)
	local dst = path.join(packagesDir, packageId)
	if not fs.exists(dst) then
		process.run({ "cp", "-r", tostring(src), tostring(dst) }, { stdio = "inherit" })
	end
end

if fs.exists(project.BUILD_OUTPUT) then
	fs.remove(project.BUILD_OUTPUT)
end

if not fs.exists(project.BUILD_PATH) then
	fs.createDirectory(project.BUILD_PATH, { makeParents = true })
end

process.run({
	"lute",
	"compile",
	"cli.luau",
	"--output",
	tostring(project.BUILD_OUTPUT),
	"--bundle-stats",
	"--show-require-graph",
}, {
	stdio = "inherit",
})
