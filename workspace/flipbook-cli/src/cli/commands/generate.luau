local cli = require("@lpm/batteries@v1.0.1-nightly.20261115/cli")
local fs = require("@std/fs")
local path = require("@std/path")
local process = require("@std/process")

local SvgButtons = require("@workspace/svg-buttons")

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
	local dir = parser:get("assets-dir") or previewButtons.DEFAULT_ASSETS_DIR
	local files = SvgButtons.generateButtons(previewButtons.BUTTONS)

	local stale = {}
	for _, file in files do
		local target = path.join(dir, file.name)
		if not fs.exists(target) or fs.readFileToString(target) ~= file.contents then
			table.insert(stale, file)
		end
	end

	if parser:has("check") then
		if #stale == 0 then
			print(`Buttons in {dir} are up to date.`)
			return
		end
		local command = if dir == previewButtons.DEFAULT_ASSETS_DIR
			then "flipbook-cli generate"
			else `flipbook-cli generate --assets-dir {dir}`
		print(`Buttons in {dir} are missing or out of date. Run \`{command}\` and commit the result:`)
		for _, file in stale do
			print(`  • {file.name}`)
		end
		process.exit(1)
	end

	if not fs.exists(dir) then
		fs.createDirectory(dir, { makeParents = true })
	end
	for _, file in stale do
		fs.writeStringToFile(path.join(dir, file.name), file.contents)
	end

	print(`Generated {#previewButtons.BUTTONS} buttons in {dir} ({#stale} files written).`)
end

local command: types.Command = {
	run = run,
	title = title,
	summary = summary,
	parser = parser,
}

return command
