local FlipbookBatteries = require("@flipbook-batteries")

local run = FlipbookBatteries.run

run("stylua", { "-c", "src", ".lute" })

run("luau-lsp", {
	"analyze",
	"--settings=./.vscode/settings.json",
	"src",
})
