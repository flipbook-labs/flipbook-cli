local storybookPreviewUrl = require("@root/storybookPreviewUrl")

export type Preview = {
	placeId: number,
	launchData: string?,
}

local function storybookPreviewComment(thumbnailUrl: string?, previews: { Preview }): string
	assert(#previews == 1 or #previews == 2, "A Storybook comment needs one or two previews")

	local sections = { "## Storybook preview" }
	local releasePreview = previews[1]
	local releaseExperienceUrl = `https://www.roblox.com/games/{releasePreview.placeId}`

	if thumbnailUrl then
		table.insert(sections, `[![Flipbook Storybook preview]({thumbnailUrl})]({releaseExperienceUrl})`)
	end

	if #previews == 1 then
		table.insert(
			sections,
			`[Experience page ↗]({releaseExperienceUrl}) · [▶ Join preview]({storybookPreviewUrl(
				releasePreview.placeId,
				releasePreview.launchData
			)})`
		)
	else
		local prPreview = previews[2]
		local prExperienceUrl = `https://www.roblox.com/games/{prPreview.placeId}`

		table.insert(sections, "Compare the latest Flipbook release with Flipbook built from this PR.")
		table.insert(
			sections,
			table.concat({
				"| Runtime | Experience |",
				"| --- | --- |",
				`| **Latest release** | [Experience page ↗]({releaseExperienceUrl}) · [▶ Join preview]({storybookPreviewUrl(
					releasePreview.placeId,
					releasePreview.launchData
				)}) |`,
				`| **This PR** | [Experience page ↗]({prExperienceUrl}) · [▶ Join preview]({storybookPreviewUrl(
					prPreview.placeId,
					prPreview.launchData
				)}) |`,
			}, "\n")
		)
	end

	return table.concat(sections, "\n\n")
end

return storybookPreviewComment
