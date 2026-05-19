local fs = require("@std/fs")
local process = require("@std/process")

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
