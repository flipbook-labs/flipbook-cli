local FlipbookBatteries = require("@pkg/flipbook-batteries@v0.9.0")

local run = FlipbookBatteries.run

run("luau-lsp", {
	"analyze",
	"--settings=./.vscode/settings.json",
	"src",
})
