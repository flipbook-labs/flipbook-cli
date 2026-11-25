local cli = require("@lpm/batteries@v1.0.1-nightly.20261115/cli")
local path = require("@std/path")
local process = require("@std/process")

local SvgButtons = require("@workspace/svg-buttons")

local buttonFiles = require("@root/buttonFiles")
local getRepositoryRoot = require("@root/getRepositoryRoot")
local previewButtons = require("@root/previewButtons")
local types = require("@root/cli/types")

local title = "generate"
local summary = "Draw the preview comment's buttons as images to commit to your repository."

local parser = cli.parser()
parser:add("assets-dir", "option", {
	help = `Folder to write the buttons to, relative to the repository root. Defaults to {previewButtons.DEFAULT_ASSETS_DIR}.`,
})
parser:add("check", "flag", {
	help = "Fail if the buttons in the folder are missing or out of date, instead of writing them.",
})
parser:add("help", "flag", {
	help = "Show this help message",
})

local function run()
	local assetsDir = parser:get("assets-dir") or previewButtons.DEFAULT_ASSETS_DIR
	local dir = path.resolve(getRepositoryRoot(), assetsDir)
	local stale = buttonFiles.findStale(dir, SvgButtons.generateButtons(previewButtons.BUTTONS))

	if parser:has("check") then
		if #stale == 0 then
			print(`Buttons in {assetsDir} are up to date.`)
			return
		end
		local command = if assetsDir == previewButtons.DEFAULT_ASSETS_DIR
			then "flipbook-cli generate"
			else `flipbook-cli generate --assets-dir {assetsDir}`
		print(`Buttons in {assetsDir} are missing or out of date. Run \`{command}\` and commit the result:`)
		for _, file in stale do
			print(`  • {file.name}`)
		end
		process.exit(1)
	end

	buttonFiles.write(dir, stale)
	print(`Generated {#previewButtons.BUTTONS} buttons in {assetsDir} ({#stale} files written).`)
end

local command: types.Command = {
	run = run,
	title = title,
	summary = summary,
	parser = parser,
}

return command
