local test = require("@std/test")

local storybookQrCodeUrl = require("@root/storybookQrCodeUrl")

test.suite("storybookQrCodeUrl", function(suite)
	suite:case("points at the backend's QR code for the place", function(assert)
		assert.eq(storybookQrCodeUrl(123), "https://apis.flipbooklabs.com/storybook/qr/123.svg")
	end)

	suite:case("passes launch data encoded the same way as the join link", function(assert)
		assert.eq(
			storybookQrCodeUrl(123, '{"search":"Button|Dialog"}'),
			"https://apis.flipbooklabs.com/storybook/qr/123.svg?launchData=%7B%22search%22%3A%22Button%7CDialog%22%7D"
		)
	end)

	suite:case("rejects non-object launch data", function(assert)
		assert.throws(function()
			storybookQrCodeUrl(123, '["Button"]')
		end)
	end)
end)
