local percentEncode = require("@root/percentEncode")

local function storybookPreviewUrl(startPlaceId: number, targetPlaceId: number): string
	local launchData = percentEncode(`placeId={targetPlaceId}`)
	return `https://www.roblox.com/games/start?placeId={startPlaceId}&launchData={launchData}`
end

return storybookPreviewUrl
