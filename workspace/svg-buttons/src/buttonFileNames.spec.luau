local test = require("@std/test")

local buttonFileNames = require("@root/buttonFileNames")

test.suite("buttonFileNames", function(suite)
	suite:case("names a light SVG, a dark SVG, and a light PNG", function(assert)
		local names = buttonFileNames("join")
		assert.eq(names.light, "join-light.svg")
		assert.eq(names.dark, "join-dark.svg")
		assert.eq(names.fallback, "join-light.png")
	end)
end)
