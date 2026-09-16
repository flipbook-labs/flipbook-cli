local test = require("@std/test")

local getUniverseThumbnail = require("@root/getUniverseThumbnail")

test.suite("getUniverseThumbnail", function(suite)
	suite:case("returns a completed experience thumbnail", function(assert)
		local thumbnailUrl = getUniverseThumbnail(
			'{"data":[{"thumbnails":[{"state":"Completed","imageUrl":"https://images.example/preview.png"}]}]}'
		)

		assert.eq(thumbnailUrl, "https://images.example/preview.png")
	end)

	suite:case("waits for a pending experience thumbnail", function(assert)
		local thumbnailUrl = getUniverseThumbnail(
			'{"data":[{"thumbnails":[{"state":"Pending","imageUrl":"https://images.example/preview.png"}]}]}'
		)

		assert.eq(thumbnailUrl, nil)
	end)

	suite:case("omits a missing experience thumbnail", function(assert)
		local thumbnailUrl = getUniverseThumbnail('{"data":[{"thumbnails":[]}]}')

		assert.eq(thumbnailUrl, nil)
	end)
end)
