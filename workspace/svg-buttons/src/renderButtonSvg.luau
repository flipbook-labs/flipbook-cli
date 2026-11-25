local vector = require("@lpm/vector@v0.16.0")

local escapeXmlAttribute = require("@root/escapeXmlAttribute")
local types = require("@root/types")

type ButtonLayers = types.ButtonLayers
type ButtonPalette = types.ButtonPalette
type Path = vector.Path

local function renderShape(path: Path, color: string): string
	return `<path d="{vector.pathToSvgData(path)}" fill="{color}"/>`
end

-- The label is drawn as shapes rather than text, because an SVG shown as an
-- image can't load web fonts.
local function renderButtonSvg(layers: ButtonLayers, palette: ButtonPalette, label: string): string
	local name = escapeXmlAttribute(label)
	local lines = {
		`<svg xmlns="http://www.w3.org/2000/svg" width="{layers.width}" height="{layers.height}" viewBox="0 0 {layers.width} {layers.height}" role="img" aria-label="{name}">`,
		renderShape(layers.border, palette.border),
		renderShape(layers.fill, palette.fill),
	}
	if #layers.icons > 0 then
		table.insert(lines, renderShape(layers.icons, palette.text))
	end
	table.insert(lines, renderShape(layers.text, palette.text))
	table.insert(lines, "</svg>")
	table.insert(lines, "")
	return table.concat(lines, "\n")
end

return renderButtonSvg
