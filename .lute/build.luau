local fs = require("@std/fs")
local path = require("@std/path")
local process = require("@std/process")

local storeDir = path.join(process.homedir(), ".loom/store")
local packagesDir = path.resolve("packages")

if not fs.exists(packagesDir) then
	fs.createDirectory(packagesDir)
end

local lock = require("../loom.lock")

process.run({
	"lute",
	"pkg",
	"install",
}, {
	stdio = "inherit",
})

for packageId in lock.packages do
	local src = path.join(storeDir, packageId)
	local dst = path.join(packagesDir, packageId)
	if not fs.exists(dst) then
		process.run({ "cp", "-r", src, dst }, { stdio = "inherit" })
	end
end

if not fs.exists("build") then
	fs.createDirectory("build")
end

process.run({
	"lute",
	"compile",
	"cli.luau",
	"--output",
	"build/flipbook-cli",
	"--bundle-stats",
	"--show-require-graph",
}, {
	stdio = "inherit",
})
