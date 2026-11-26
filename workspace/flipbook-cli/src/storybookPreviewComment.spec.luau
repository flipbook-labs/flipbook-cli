local test = require("@std/test")

local storybookPreviewComment = require("@root/storybookPreviewComment")

local BASE_URL = "https://raw.githubusercontent.com/owner/repo/main/.github/deploy-storybook/assets"

test.suite("storybookPreviewComment", function(suite)
	suite:case("renders buttons beside the thumbnail with a footer", function(assert)
		local body = storybookPreviewComment({
			buttonsBaseUrl = BASE_URL,
			placeId = 101,
			publishedFrom = {
				sha = "1b829ec0123456789",
				runNumber = "42",
				runUrl = "https://github.com/owner/repo/actions/runs/9",
			},
			thumbnailUrl = "https://images.example/preview.png",
		})

		assert.eq(
			body,
			(
				string.gsub(
					[[<a href="https://www.roblox.com/games/101"><img src="https://images.example/preview.png" alt="Flipbook Storybook preview" align="right" width="30%"></a>

<a href="https://www.roblox.com/games/start?placeId=101"><picture><source media="(prefers-color-scheme: dark)" srcset="BASE_URL/join-dark.svg"><source media="(prefers-color-scheme: light)" srcset="BASE_URL/join-light.svg"><img src="BASE_URL/join-light.png" alt="Open Storybook" height="32"></picture></a> <a href="https://www.roblox.com/games/101"><picture><source media="(prefers-color-scheme: dark)" srcset="BASE_URL/experience-dark.svg"><source media="(prefers-color-scheme: light)" srcset="BASE_URL/experience-light.svg"><img src="BASE_URL/experience-light.png" alt="View on Roblox" height="32"></picture></a>

<sub>Published from 1b829ec in [run 42](https://github.com/owner/repo/actions/runs/9). Each push replaces this comment.</sub>]],
					"BASE_URL",
					BASE_URL
				)
			)
		)
	end)

	suite:case("falls back to text links without buttons", function(assert)
		local body = storybookPreviewComment({
			placeId = 101,
		})

		assert.eq(
			body,
			[[- [▶ Open Storybook](https://www.roblox.com/games/start?placeId=101)
- [View on Roblox ↗](https://www.roblox.com/games/101)]]
		)
	end)

	suite:case("names only the commit outside a workflow run", function(assert)
		local body = storybookPreviewComment({
			placeId = 101,
			publishedFrom = { sha = "1b829ec0123456789" },
		})

		assert.strContains(body, "<sub>Published from 1b829ec. Each push replaces this comment.</sub>")
	end)

	suite:case("renders a custom preview template", function(assert)
		local body = storybookPreviewComment({
			buttonsBaseUrl = BASE_URL,
			placeId = 101,
			launchData = '{"search":"Button"}',
			publishedFrom = { sha = "1b829ec0123456789" },
			template = [[## Component preview

{{thumbnailMarkdown}}

[Open experience]({{experienceUrl}}) · [Join focused preview]({{launchUrl}})

Raw image: {{thumbnailUrl}}]],
			thumbnailUrl = "https://images.example/preview%20image.png",
		})

		assert.eq(
			body,
			[[## Component preview

[![Flipbook Storybook preview](https://images.example/preview%20image.png)](https://www.roblox.com/games/101)

[Open experience](https://www.roblox.com/games/101) · [Join focused preview](https://www.roblox.com/games/start?placeId=101&launchData=%7B%22search%22%3A%22Button%22%7D)

Raw image: https://images.example/preview%20image.png]]
		)
	end)

	suite:case("fills each button placeholder in a custom template", function(assert)
		local body = storybookPreviewComment({
			buttonsBaseUrl = BASE_URL,
			placeId = 101,
			template = "{{launchButton}}\n\n{{experienceButton}}",
		})

		assert.strContains(body, `<a href="https://www.roblox.com/games/start?placeId=101"><picture>`)
		assert.strContains(body, `alt="Open Storybook"`)
		assert.strContains(body, `<a href="https://www.roblox.com/games/101"><picture>`)
		assert.strContains(body, `alt="View on Roblox"`)
	end)

	suite:case("fills button placeholders with text links without buttons", function(assert)
		local body = storybookPreviewComment({
			placeId = 101,
			template = "{{launchButton}} · {{experienceButton}}",
		})

		assert.eq(
			body,
			"[▶ Open Storybook](https://www.roblox.com/games/start?placeId=101) · [View on Roblox ↗](https://www.roblox.com/games/101)"
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
