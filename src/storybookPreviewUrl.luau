local json = require("@std/json")

local percentEncode = require("@root/percentEncode")

local function storybookPreviewUrl(placeId: number, launchData: string?): string
	local url = `https://www.roblox.com/games/start?placeId={placeId}`

	if launchData then
		assert(launchData:match("^%s*{"), "launch data must be a JSON object")
		local decodedLaunchData = json.deserialize(launchData) :: json.Object
		local encodedLaunchData = percentEncode(json.serialize(decodedLaunchData))
		url ..= `&launchData={encodedLaunchData}`
	end

	return url
end

return storybookPreviewUrl
