local storybookPreviewUrl = require("@root/storybookPreviewUrl")
local storybookQrCodeUrl = require("@root/storybookQrCodeUrl")

export type Options = {
	launchData: string?,
	placeId: number,
	template: string?,
	thumbnailUrl: string?,
}

local QR_CODE_ALT_TEXT = "QR code for the Storybook preview join link"

-- A reviewer reading the pull request on a computer can scan this with their
-- phone to open the preview there. It stays collapsed so it doesn't push the
-- links down.
local MOBILE_PREVIEW = [[<details>
<summary>📱 Preview on mobile</summary>

Scan to join the preview in the Roblox app.

<a href="{{launchUrl}}"><img src="{{qrCodeUrl}}" alt="]] .. QR_CODE_ALT_TEXT .. [[" width="160"></a>

</details>]]

local DEFAULT_TEMPLATE = [[## Storybook preview

- [Experience page ↗]({{experienceUrl}})
- [▶ Join preview]({{launchUrl}})

]] .. MOBILE_PREVIEW

local DEFAULT_TEMPLATE_WITH_THUMBNAIL = [[## Storybook preview

<a href="{{experienceUrl}}"><img src="{{thumbnailUrl}}" alt="Flipbook Storybook preview" align="right" width="30%"></a>

- [Experience page ↗]({{experienceUrl}})
- [▶ Join preview]({{launchUrl}})

]] .. MOBILE_PREVIEW

local function storybookPreviewComment(options: Options): string
	local experienceUrl = `https://www.roblox.com/games/{options.placeId}`
	local launchUrl = storybookPreviewUrl(options.placeId, options.launchData)
	local qrCodeUrl = storybookQrCodeUrl(options.placeId, options.launchData)
	local thumbnailUrl = options.thumbnailUrl or ""
	local thumbnailMarkdown = if options.thumbnailUrl
		then `[![Flipbook Storybook preview]({options.thumbnailUrl})]({experienceUrl})`
		else ""

	local replacements: { [string]: string } = {
		experienceUrl = experienceUrl,
		launchUrl = launchUrl,
		qrCodeMarkdown = `[![{QR_CODE_ALT_TEXT}]({qrCodeUrl})]({launchUrl})`,
		qrCodeUrl = qrCodeUrl,
		thumbnailMarkdown = thumbnailMarkdown,
		thumbnailUrl = thumbnailUrl,
	}
	local template = options.template
		or if options.thumbnailUrl then DEFAULT_TEMPLATE_WITH_THUMBNAIL else DEFAULT_TEMPLATE

	local comment = template:gsub("{{([^{}]+)}}", function(placeholder)
		local replacement = replacements[placeholder]
		if replacement == nil then
			error(`Unknown comment template placeholder "{placeholder}"`)
		end
		return replacement
	end)
	return comment
end

return storybookPreviewComment
