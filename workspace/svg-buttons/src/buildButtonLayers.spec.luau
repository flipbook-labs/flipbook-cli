local test = require("@std/test")

local buildButtonLayers = require("@root/buildButtonLayers")
local buttonDrawing = require("@root/buttonDrawing")
local getButtonFont = require("@root/getButtonFont")
local types = require("@root/types")

type ButtonSpec = types.ButtonSpec

local PALETTE = { fill = "#ffffff", border = "#000000", text = "#000000" }

local function spec(overrides: { [string]: any }): ButtonSpec
	local base: { [string]: any } = {
		name = "join",
		label = "Join preview",
		colorMode = { light = PALETTE, dark = PALETTE },
	}
	for key, value in overrides do
		base[key] = value
	end
	return base :: any
end

test.suite("buildButtonLayers", function(suite)
	local font = getButtonFont()
	local metrics = buttonDrawing.metrics

	suite:case("sizes the button to its label and padding on a whole pixel", function(assert)
		local layers = buildButtonLayers(font, spec({}), metrics)

		assert.eq(layers.height, metrics.height)
		assert.eq(layers.width, math.floor(layers.width))
		assert.eq(layers.width > metrics.paddingX * 2, true)
		assert.eq(#layers.icons, 0)
	end)

	suite:case("widens the button for each icon", function(assert)
		local plain = buildButtonLayers(font, spec({}), metrics)
		local leading = buildButtonLayers(font, spec({ leadingIcon = "play" }), metrics)
		local both = buildButtonLayers(font, spec({ leadingIcon = "play", trailingIcon = "external" }), metrics)
		local iconSpan = metrics.iconSize + metrics.iconGap

		assert.eq(leading.width - plain.width <= iconSpan + 1, true)
		assert.eq(leading.width - plain.width >= iconSpan - 1, true)
		assert.eq(both.width > leading.width, true)
		assert.eq(#leading.icons > 0, true)
	end)

	suite:case("starts the label after a leading icon", function(assert)
		local plain = buildButtonLayers(font, spec({}), metrics)
		local leading = buildButtonLayers(font, spec({ leadingIcon = "play" }), metrics)
		local plainStart = plain.text[1] :: any
		local leadingStart = leading.text[1] :: any

		assert.eq(leadingStart.x - plainStart.x, metrics.iconSize + metrics.iconGap)
	end)

	suite:case("places a trailing icon after the label", function(assert)
		local layers = buildButtonLayers(font, spec({ trailingIcon = "external" }), metrics)
		local maxTextX = 0
		for _, command in layers.text do
			local point = command :: any
			if point.x then
				maxTextX = math.max(maxTextX, point.x)
			end
		end
		local minIconX = math.huge
		for _, command in layers.icons do
			local point = command :: any
			if point.x then
				minIconX = math.min(minIconX, point.x)
			end
		end

		assert.eq(minIconX > maxTextX, true)
	end)
end)
