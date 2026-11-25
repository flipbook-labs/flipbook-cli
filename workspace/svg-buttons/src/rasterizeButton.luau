local png = require("@lpm/png@v0.16.0")
local vector = require("@lpm/vector@v0.16.0")

local types = require("@root/types")

type ButtonLayers = types.ButtonLayers
type ButtonPalette = types.ButtonPalette
type Color = vector.Color
type Image = png.Image

local function toColor(hex: string): Color
	local r, g, b = vector.parseHexColor(hex)
	return { r = r, g = g, b = b, a = 1 }
end

-- Paints the button's layers in the same order as the SVG, onto a transparent
-- image `scale` times the button's size.
local function rasterizeButton(layers: ButtonLayers, palette: ButtonPalette, scale: number): Image
	local canvas = vector.createCanvas(layers.width * scale, layers.height * scale, scale)
	canvas.fillPath(layers.border, toColor(palette.border))
	canvas.fillPath(layers.fill, toColor(palette.fill))
	canvas.fillPath(layers.icons, toColor(palette.text))
	canvas.fillPath(layers.text, toColor(palette.text))

	return {
		width = canvas.width,
		height = canvas.height,
		pixels = canvas.toRgba(),
	}
end

return rasterizeButton
