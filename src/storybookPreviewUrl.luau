local function storybookPreviewUrl(prNumber: number, placeId: string): string
	local encodedRoot = "storyRoot%3DPRStorybooks%2Fpr-" .. prNumber
	return "https://www.roblox.com/games/" .. placeId .. "?launchData=" .. encodedRoot
end

return storybookPreviewUrl
