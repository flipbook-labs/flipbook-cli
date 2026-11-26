local test = require("@std/test")

local renderButtonSvg = require("@root/renderButtonSvg")
local types = require("@root/types")

type ButtonLayers = types.ButtonLayers
type Path = types.Path

local PALETTE = { fill = "#8250df", border = "#6639ba", text = "#ffffff" }

local function emptyLayers(icons: Path): ButtonLayers
	return {
		width = 120,
		height = 32,
		border = {},
		fill = {},
		icons = icons,
		text = {},
	}
end

test.suite("renderButtonSvg", function(suite)
	suite:case("names the button by its label, escaped", function(assert)
		local svg = renderButtonSvg(emptyLayers({}), PALETTE, 'Join "R&D"')

		assert.strContains(svg, 'aria-label="Join &quot;R&amp;D&quot;"')
		assert.strContains(svg, 'width="120" height="32" viewBox="0 0 120 32"')
	end)

	suite:case("paints the border, fill, and label in the palette's colors", function(assert)
		local svg = renderButtonSvg(emptyLayers({}), PALETTE, "Join")

		assert.strContains(svg, 'fill="#6639ba"')
		assert.strContains(svg, 'fill="#8250df"')
		assert.strContains(svg, 'fill="#ffffff"')
	end)

	suite:case("leaves out the icon shape when the button has none", function(assert)
		local plain = renderButtonSvg(emptyLayers({}), PALETTE, "Join")
		local withIcon = renderButtonSvg(emptyLayers({ { op = "M", x = 0, y = 0 }, { op = "Z" } }), PALETTE, "Join")

		local _, plainShapes = plain:gsub("<path", "")
		local _, iconShapes = withIcon:gsub("<path", "")
		assert.eq(plainShapes, 3)
		assert.eq(iconShapes, 4)
	end)
end)
