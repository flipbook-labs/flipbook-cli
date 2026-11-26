local SvgButtons = require("@workspace/svg-buttons")

local previewButtons = require("@root/previewButtons")
local storybookPreviewUrl = require("@root/storybookPreviewUrl")
local storybookQrCodeUrl = require("@root/storybookQrCodeUrl")

export type PublishedFrom = {
	sha: string,
	runNumber: string?,
	runUrl: string?,
}

export type Options = {
	-- Where the button images live, such as a raw.githubusercontent.com folder.
	-- Each button falls back to a text link when this is nil.
	buttonsBaseUrl: string?,
	launchData: string?,
	placeId: number,
	publishedFrom: PublishedFrom?,
	template: string?,
	thumbnailUrl: string?,
}

local BUTTON_HEIGHT = 32

local QR_CODE_ALT_TEXT = "QR code for the Storybook preview join link"

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

-- The text link a button falls back to when its images can't load.
local function renderLink(name: string, href: string): string
	local label = getButtonLabel(name)
	return if name == "join" then `[▶ {label}]({href})` else `[{label} ↗]({href})`
end

-- A reviewer reading the pull request on a computer can scan this with their
-- phone to open the preview there. It stays collapsed so it doesn't push the
-- footer down.
local function renderMobilePreview(launchUrl: string, qrCodeUrl: string): string
	return table.concat({
		"<details>",
		"<summary>📱 Preview on mobile</summary>",
		"",
		"Scan to join the preview in the Roblox app.",
		"",
		`<a href="{launchUrl}"><img src="{qrCodeUrl}" alt="{QR_CODE_ALT_TEXT}" width="160"></a>`,
		"",
		"</details>",
	}, "\n")
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
	local qrCodeUrl = storybookQrCodeUrl(options.placeId, options.launchData)
	local buttonsBaseUrl = options.buttonsBaseUrl
	local launchButton = if buttonsBaseUrl
		then renderButton(buttonsBaseUrl, "join", launchUrl)
		else renderLink("join", launchUrl)
	local experienceButton = if buttonsBaseUrl
		then renderButton(buttonsBaseUrl, "experience", experienceUrl)
		else renderLink("experience", experienceUrl)

	if options.template then
		return renderTemplate(options.template, {
			experienceButton = experienceButton,
			experienceUrl = experienceUrl,
			launchButton = launchButton,
			launchUrl = launchUrl,
			qrCodeMarkdown = `[![{QR_CODE_ALT_TEXT}]({qrCodeUrl})]({launchUrl})`,
			qrCodeUrl = qrCodeUrl,
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

	-- Buttons sit side by side. Text links stack as a list so each reads as
	-- its own action.
	table.insert(
		sections,
		if buttonsBaseUrl then `{launchButton} {experienceButton}` else `- {launchButton}\n- {experienceButton}`
	)

	table.insert(sections, renderMobilePreview(launchUrl, qrCodeUrl))

	if options.publishedFrom then
		table.insert(sections, renderFooter(options.publishedFrom))
	end

	return table.concat(sections, "\n\n")
end

return storybookPreviewComment
