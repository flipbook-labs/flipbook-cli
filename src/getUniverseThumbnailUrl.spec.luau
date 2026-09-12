local test = require("@std/test")

local getUniverseThumbnailUrl = require("@root/getUniverseThumbnailUrl")

test.suite("getUniverseThumbnailUrl", function(suite)
	suite:case("returns a completed experience thumbnail", function(assert)
		local thumbnailUrl = getUniverseThumbnailUrl(
			'{"data":[{"thumbnails":[{"state":"Completed","imageUrl":"https://images.example/preview.png"}]}]}'
		)

		assert.eq(thumbnailUrl, "https://images.example/preview.png")
	end)

	suite:case("waits for a pending experience thumbnail", function(assert)
		local thumbnailUrl = getUniverseThumbnailUrl(
			'{"data":[{"thumbnails":[{"state":"Pending","imageUrl":"https://images.example/preview.png"}]}]}'
		)

		assert.eq(thumbnailUrl, nil)
	end)

	suite:case("omits a missing experience thumbnail", function(assert)
		local thumbnailUrl = getUniverseThumbnailUrl('{"data":[{"thumbnails":[]}]}')

		assert.eq(thumbnailUrl, nil)
	end)
end)
