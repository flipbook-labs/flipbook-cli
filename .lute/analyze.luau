local FlipbookBatteries = require("@pkg/flipbook-batteries@bump-tool-version")

local run = FlipbookBatteries.run

run("stylua", { "-c", "src", ".lute" })

run("luau-lsp", {
	"analyze",
	"--settings=./.vscode/settings.json",
	"src",
})
