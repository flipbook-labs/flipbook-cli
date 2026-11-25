local test = require("@std/test")

local roundedRectPath = require("@root/roundedRectPath")

test.suite("roundedRectPath", function(suite)
	suite:case("starts each side where the corner curve ends", function(assert)
		local path = roundedRectPath(10, 20, 100, 32, 6)
		local first = path[1] :: any

		assert.eq(first.op, "M")
		assert.eq(first.x, 16)
		assert.eq(first.y, 20)
	end)

	suite:case("limits the corner radius to half the shorter side", function(assert)
		local path = roundedRectPath(0, 0, 100, 10, 40)
		local first = path[1] :: any

		assert.eq(first.x, 5)
	end)

	suite:case("traces the counterclockwise outline from the top right", function(assert)
		local path = roundedRectPath(0, 0, 100, 32, 6, true)
		local first = path[1] :: any
		local second = path[2] :: any

		assert.eq(first.x, 94)
		assert.eq(second.x, 6)
	end)
end)
