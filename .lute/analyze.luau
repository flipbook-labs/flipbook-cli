local FlipbookBatteries = require("@FlipbookBatteries")

local run = FlipbookBatteries.run

run("stylua", { "-c", "src", ".lute" })

run("luau-lsp", {
	"analyze",
	"--settings=./.vscode/settings.json",
	"src",
})
