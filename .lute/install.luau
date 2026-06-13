local process = require("@std/process")

process.run({
	"lute",
	"pkg",
	"install",
}, {
	stdio = "inherit",
})
