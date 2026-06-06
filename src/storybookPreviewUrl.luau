local json = require("@std/json")

local percentEncode = require("@root/percentEncode")

local function storybookPreviewUrl(placeId: number, launchData: json.Object?): string
	local url = `https://www.roblox.com/games/start?placeId={placeId}`

	if launchData then
		local encodedLaunchData = percentEncode(json.serialize(launchData))
		url ..= `&launchData={encodedLaunchData}`
	end

	return url
end

return storybookPreviewUrl
