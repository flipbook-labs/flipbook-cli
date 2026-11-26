local test = require("@std/test")

local storybookPreviewComment = require("@root/storybookPreviewComment")

test.suite("storybookPreviewComment", function(suite)
	suite:case("renders one preview with explicit experience links", function(assert)
		local body = storybookPreviewComment({
			placeId = 101,
			thumbnailUrl = "https://images.example/preview.png",
		})

		assert.eq(
			body,
			[[## Storybook preview

<a href="https://www.roblox.com/games/101"><img src="https://images.example/preview.png" alt="Flipbook Storybook preview" align="right" width="30%"></a>

- [Experience page ↗](https://www.roblox.com/games/101)
- [▶ Join preview](https://www.roblox.com/games/start?placeId=101)

<details>
<summary>📱 Preview on mobile</summary>

Scan to join the preview in the Roblox app.

<a href="https://www.roblox.com/games/start?placeId=101"><img src="https://apis.flipbooklabs.com/storybook/qr/101.svg" alt="QR code for the Storybook preview join link" width="160"></a>

</details>]]
		)
	end)

	suite:case("renders the default preview without a thumbnail", function(assert)
		local body = storybookPreviewComment({
			placeId = 101,
		})

		assert.eq(
			body,
			[[## Storybook preview

- [Experience page ↗](https://www.roblox.com/games/101)
- [▶ Join preview](https://www.roblox.com/games/start?placeId=101)

<details>
<summary>📱 Preview on mobile</summary>

Scan to join the preview in the Roblox app.

<a href="https://www.roblox.com/games/start?placeId=101"><img src="https://apis.flipbooklabs.com/storybook/qr/101.svg" alt="QR code for the Storybook preview join link" width="160"></a>

</details>]]
		)
	end)

	suite:case("encodes launch data into the QR code URL", function(assert)
		local body = storybookPreviewComment({
			placeId = 101,
			launchData = '{"search":"Button"}',
			template = "{{launchUrl}}\n{{qrCodeUrl}}",
		})

		assert.eq(
			body,
			"https://www.roblox.com/games/start?placeId=101&launchData=%7B%22search%22%3A%22Button%22%7D\n"
				.. "https://apis.flipbooklabs.com/storybook/qr/101.svg?launchData=%7B%22search%22%3A%22Button%22%7D"
		)
	end)

	suite:case("renders a custom preview template", function(assert)
		local body = storybookPreviewComment({
			placeId = 101,
			launchData = '{"search":"Button"}',
			template = [[## Component preview

{{thumbnailMarkdown}}

[Open experience]({{experienceUrl}}) · [Join focused preview]({{launchUrl}})

Raw image: {{thumbnailUrl}}

{{qrCodeMarkdown}}]],
			thumbnailUrl = "https://images.example/preview%20image.png",
		})

		assert.eq(
			body,
			[[## Component preview

[![Flipbook Storybook preview](https://images.example/preview%20image.png)](https://www.roblox.com/games/101)

[Open experience](https://www.roblox.com/games/101) · [Join focused preview](https://www.roblox.com/games/start?placeId=101&launchData=%7B%22search%22%3A%22Button%22%7D)

Raw image: https://images.example/preview%20image.png

[![QR code for the Storybook preview join link](https://apis.flipbooklabs.com/storybook/qr/101.svg?launchData=%7B%22search%22%3A%22Button%22%7D)](https://www.roblox.com/games/start?placeId=101&launchData=%7B%22search%22%3A%22Button%22%7D)]]
		)
	end)

	suite:case("omits unavailable thumbnail placeholders", function(assert)
		local body = storybookPreviewComment({
			placeId = 101,
			template = "{{thumbnailUrl}}|{{thumbnailMarkdown}}|{{experienceUrl}}|{{launchUrl}}",
		})

		assert.eq(body, "||https://www.roblox.com/games/101|https://www.roblox.com/games/start?placeId=101")
	end)

	suite:case("rejects unknown template placeholders", function(assert)
		assert.throws(function()
			storybookPreviewComment({
				placeId = 101,
				template = "{{unknown}}",
			})
		end)
	end)
end)
