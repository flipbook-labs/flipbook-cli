local test = require("@std/test")

local storybookPreviewComment = require("@root/storybookPreviewComment")

test.suite("storybookPreviewComment", function(suite)
	suite:case("renders one preview with explicit experience links", function(assert)
		local body = storybookPreviewComment("https://images.example/preview.png", {
			{
				placeId = 101,
				launchData = nil,
			},
		})

		assert.eq(
			body,
			[[## Storybook preview

[![Flipbook Storybook preview](https://images.example/preview.png)](https://www.roblox.com/games/101)

[Experience page ↗](https://www.roblox.com/games/101) · [▶ Join preview](https://www.roblox.com/games/start?placeId=101)]]
		)
	end)

	suite:case("compares the release and pull request runtimes", function(assert)
		local body = storybookPreviewComment(nil, {
			{
				placeId = 101,
				launchData = '{"search":"Button"}',
			},
			{
				placeId = 202,
				launchData = '{"search":"Button"}',
			},
		})

		assert.eq(
			body,
			[[## Storybook preview

Compare the latest Flipbook release with Flipbook built from this PR.

| Runtime | Experience |
| --- | --- |
| **Latest release** | [Experience page ↗](https://www.roblox.com/games/101) · [▶ Join preview](https://www.roblox.com/games/start?placeId=101&launchData=%7B%22search%22%3A%22Button%22%7D) |
| **This PR** | [Experience page ↗](https://www.roblox.com/games/202) · [▶ Join preview](https://www.roblox.com/games/start?placeId=202&launchData=%7B%22search%22%3A%22Button%22%7D) |]]
		)
	end)
end)
