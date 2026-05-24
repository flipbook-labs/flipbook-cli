local percentEncode = require("@root/percentEncode")

local function storybookPreviewUrl(startPlaceId: number, targetPlaceId: number): string
	if startPlaceId == targetPlaceId then
		return "https://www.roblox.com/games/" .. targetPlaceId
	end

	local launchData = percentEncode(`placeId={targetPlaceId}`)
	return `https://www.roblox.com/games/start?placeId={startPlaceId}&launchData={launchData}`
end

return storybookPreviewUrl
