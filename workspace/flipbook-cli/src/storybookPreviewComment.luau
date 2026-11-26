local SvgButtons = require("@workspace/svg-buttons")

local previewButtons = require("@root/previewButtons")
local storybookPreviewUrl = require("@root/storybookPreviewUrl")

export type PublishedFrom = {
	sha: string,
	runNumber: string?,
	runUrl: string?,
}

export type Options = {
	-- Where the button images live, such as a raw.githubusercontent.com folder.
	-- The comment shows text links instead when this is nil.
	buttonsBaseUrl: string?,
	launchData: string?,
	placeId: number,
	publishedFrom: PublishedFrom?,
	template: string?,
	thumbnailUrl: string?,
}

local BUTTON_HEIGHT = 32

local function getButtonLabel(name: string): string
	for _, button in previewButtons.BUTTONS do
		if button.name == name then
			return button.label
		end
	end
	error(`No preview button named "{name}"`)
end

-- A linked button that follows GitHub's light or dark mode. Viewers that skip
-- `<source>`, such as notification emails, get the light PNG.
local function renderButton(baseUrl: string, name: string, href: string): string
	local names = SvgButtons.buttonFileNames(name)
	return `<a href="{href}"><picture>`
		.. `<source media="(prefers-color-scheme: dark)" srcset="{baseUrl}/{names.dark}">`
		.. `<source media="(prefers-color-scheme: light)" srcset="{baseUrl}/{names.light}">`
		.. `<img src="{baseUrl}/{names.fallback}" alt="{getButtonLabel(name)}" height="{BUTTON_HEIGHT}">`
		.. `</picture></a>`
end

local function renderFooter(publishedFrom: PublishedFrom): string
	local sha = string.sub(publishedFrom.sha, 1, 7)
	local run = if publishedFrom.runNumber and publishedFrom.runUrl
		then ` in [run {publishedFrom.runNumber}]({publishedFrom.runUrl})`
		else ""
	return `<sub>Published from {sha}{run}. Each push replaces this comment.</sub>`
end

local function renderTemplate(template: string, replacements: { [string]: string }): string
	local comment = template:gsub("{{([^{}]+)}}", function(placeholder)
		local replacement = replacements[placeholder]
		if replacement == nil then
			error(`Unknown comment template placeholder "{placeholder}"`)
		end
		return replacement
	end)
	return comment
end

local function storybookPreviewComment(options: Options): string
	local experienceUrl = `https://www.roblox.com/games/{options.placeId}`
	local launchUrl = storybookPreviewUrl(options.placeId, options.launchData)

	if options.template then
		return renderTemplate(options.template, {
			experienceUrl = experienceUrl,
			launchUrl = launchUrl,
			thumbnailMarkdown = if options.thumbnailUrl
				then `[![Flipbook Storybook preview]({options.thumbnailUrl})]({experienceUrl})`
				else "",
			thumbnailUrl = options.thumbnailUrl or "",
		})
	end

	local sections: { string } = {}

	if options.thumbnailUrl then
		table.insert(
			sections,
			`<a href="{experienceUrl}"><img src="{options.thumbnailUrl}" alt="Flipbook Storybook preview" align="right" width="30%"></a>`
		)
	end

	if options.buttonsBaseUrl then
		table.insert(
			sections,
			`{renderButton(options.buttonsBaseUrl, "join", launchUrl)} {renderButton(
				options.buttonsBaseUrl,
				"experience",
				experienceUrl
			)}`
		)
	else
		table.insert(
			sections,
			`- [▶ {getButtonLabel("join")}]({launchUrl})\n- [{getButtonLabel("experience")} ↗]({experienceUrl})`
		)
	end

	if options.publishedFrom then
		table.insert(sections, renderFooter(options.publishedFrom))
	end

	return table.concat(sections, "\n\n")
end

return storybookPreviewComment
