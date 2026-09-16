local storybookPreviewUrl = require("@root/storybookPreviewUrl")

export type Options = {
	launchData: string?,
	placeId: number,
	template: string?,
	thumbnailUrl: string?,
}

local DEFAULT_TEMPLATE = [[## Storybook preview

[Experience page ↗]({{experienceUrl}}) · [▶ Join preview]({{launchUrl}})]]

local DEFAULT_TEMPLATE_WITH_THUMBNAIL = [[## Storybook preview

{{thumbnailMarkdown}}

[Experience page ↗]({{experienceUrl}}) · [▶ Join preview]({{launchUrl}})]]

local function storybookPreviewComment(options: Options): string
	local experienceUrl = `https://www.roblox.com/games/{options.placeId}`
	local launchUrl = storybookPreviewUrl(options.placeId, options.launchData)
	local thumbnailUrl = options.thumbnailUrl or ""
	local thumbnailMarkdown = if options.thumbnailUrl
		then `[![Flipbook Storybook preview]({options.thumbnailUrl})]({experienceUrl})`
		else ""

	local replacements: { [string]: string } = {
		experienceUrl = experienceUrl,
		launchUrl = launchUrl,
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
