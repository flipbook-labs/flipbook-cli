local truetype = require("@lpm/truetype@v0.16.0")
local vector = require("@lpm/vector@v0.16.0")

local iconPath = require("@root/iconPath")
local roundedRectPath = require("@root/roundedRectPath")
local types = require("@root/types")

type ButtonLayers = types.ButtonLayers
type ButtonMetrics = types.ButtonMetrics
type ButtonSpec = types.ButtonSpec
type Font = truetype.Font
type Path = vector.Path

local function append(path: Path, commands: Path)
	for _, command in commands do
		table.insert(path, command)
	end
end

-- Lays out one button: a bordered rounded rectangle, then an optional leading
-- icon, the label, and an optional trailing icon in a row. The width is
-- rounded up to a whole pixel so the button sits on the pixel grid wherever
-- it's shown, and the extra fraction goes to the right padding.
local function buildButtonLayers(font: Font, spec: ButtonSpec, metrics: ButtonMetrics): ButtonLayers
	local labelWidth = truetype.measureText(font, spec.label, metrics.fontSize, metrics.letterSpacing)
	local iconSpan = metrics.iconSize + metrics.iconGap
	local contentWidth = labelWidth
		+ (if spec.leadingIcon then iconSpan else 0)
		+ (if spec.trailingIcon then iconSpan else 0)
	local width = math.ceil(metrics.paddingX * 2 + contentWidth)
	local height = metrics.height
	local inset = metrics.borderWidth
	local innerRadius = metrics.cornerRadius - inset

	local border = roundedRectPath(0, 0, width, height, metrics.cornerRadius)
	append(border, roundedRectPath(inset, inset, width - inset * 2, height - inset * 2, innerRadius, true))

	local iconY = (height - metrics.iconSize) / 2
	local icons: Path = {}
	local cursor = metrics.paddingX
	if spec.leadingIcon then
		append(icons, iconPath(spec.leadingIcon, cursor, iconY, metrics.iconSize))
		cursor += iconSpan
	end

	local capHeight = font.capHeight * metrics.fontSize / font.unitsPerEm
	local baselineY = (height + capHeight) / 2
	local text: Path = {}
	for _, command in truetype.layoutText(font, spec.label, cursor, baselineY, metrics.fontSize, metrics.letterSpacing) do
		table.insert(text, command)
	end
	cursor += labelWidth

	if spec.trailingIcon then
		append(icons, iconPath(spec.trailingIcon, cursor + metrics.iconGap, iconY, metrics.iconSize))
	end

	return {
		width = width,
		height = height,
		border = border,
		fill = roundedRectPath(inset, inset, width - inset * 2, height - inset * 2, innerRadius),
		icons = icons,
		text = text,
	}
end

return buildButtonLayers
