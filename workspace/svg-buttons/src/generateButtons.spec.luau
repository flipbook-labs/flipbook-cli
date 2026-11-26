local test = require("@std/test")

local generateButtons = require("@root/generateButtons")

local LIGHT = { fill = "#ffffff", border = "#d1d9e0", text = "#25292e" }
local DARK = { fill = "#212830", border = "#3d444d", text = "#f0f6fc" }

test.suite("generateButtons", function(suite)
	suite:case("writes a light SVG, a dark SVG, and a light PNG per button", function(assert)
		local files = generateButtons({
			{
				name = "experience",
				label = "Experience page",
				trailingIcon = "external",
				colorMode = { light = LIGHT, dark = DARK },
			},
		})

		assert.eq(#files, 3)
		assert.eq(files[1].name, "experience-light.svg")
		assert.eq(files[2].name, "experience-dark.svg")
		assert.eq(files[3].name, "experience-light.png")
		assert.strContains(files[1].contents, 'fill="#d1d9e0"')
		assert.strContains(files[2].contents, 'fill="#3d444d"')
		assert.eq(files[3].contents:sub(1, 8), "\137PNG\r\n\26\n")
	end)
end)
