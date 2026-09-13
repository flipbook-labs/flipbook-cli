local test = require("@std/test")

local storybookPreviewUrl = require("@root/storybookPreviewUrl")

test.suite("storybookPreviewUrl", function(suite)
	suite:case("includes encoded launch data", function(assert)
		assert.eq(
			storybookPreviewUrl(123, '{"search":"Button|Dialog"}'),
			"https://www.roblox.com/games/start?placeId=123&launchData=%7B%22search%22%3A%22Button%7CDialog%22%7D"
		)
	end)

	suite:case("rejects non-object launch data", function(assert)
		assert.throws(function()
			storybookPreviewUrl(123, '["Button"]')
		end)
	end)
end)
