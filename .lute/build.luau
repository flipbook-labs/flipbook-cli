local fs = require("@std/fs")
local process = require("@std/process")

if not fs.exists("build") then
	fs.createDirectory("build")
end

local compileArgs = {
	"lute",
	"compile",
	"cli.luau",
	"--output",
	"build/flipbook-cli",
}

table.insert(compileArgs, "--bundle-stats")
table.insert(compileArgs, "--show-require-graph")

process.run(compileArgs, {
	stdio = "inherit",
})
