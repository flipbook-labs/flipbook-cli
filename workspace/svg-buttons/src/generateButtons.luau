local png = require("@lpm/png@v0.16.0")

local buildButtonLayers = require("@root/buildButtonLayers")
local buttonDrawing = require("@root/buttonDrawing")
local buttonFileNames = require("@root/buttonFileNames")
local getButtonFont = require("@root/getButtonFont")
local rasterizeButton = require("@root/rasterizeButton")
local renderButtonSvg = require("@root/renderButtonSvg")
local types = require("@root/types")

type ButtonFile = types.ButtonFile
type ButtonSpec = types.ButtonSpec

-- Produces every file for a set of buttons: a light and a dark SVG for each,
-- and a light PNG for places that don't show SVG, such as notification emails.
local function generateButtons(buttons: { ButtonSpec }): { ButtonFile }
	local font = getButtonFont()
	local files: { ButtonFile } = {}
	for _, button in buttons do
		local layers = buildButtonLayers(font, button, buttonDrawing.metrics)
		local names = buttonFileNames(button.name)
		table.insert(files, {
			name = names.light,
			contents = renderButtonSvg(layers, button.colorMode.light, button.label),
		})
		table.insert(files, {
			name = names.dark,
			contents = renderButtonSvg(layers, button.colorMode.dark, button.label),
		})
		table.insert(files, {
			name = names.fallback,
			contents = png.encodePng(rasterizeButton(layers, button.colorMode.light, buttonDrawing.pngScale)),
		})
	end
	return files
end

return generateButtons
