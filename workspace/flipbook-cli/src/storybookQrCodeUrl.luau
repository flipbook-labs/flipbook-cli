local json = require("@std/json")

local percentEncode = require("@root/percentEncode")

-- GitHub comments can't embed an image, only link to one at a public URL. Each
-- preview has its own join link, so its QR code can't be drawn ahead of time,
-- and flipbook-backend (served at apis.flipbooklabs.com) draws it on request.
-- The backend builds the join link from the place ID and launch data itself,
-- so it can't be used to encode arbitrary addresses.
local QR_CODE_BASE_URL = "https://apis.flipbooklabs.com/storybook/qr"

-- Returns the URL of a QR code image for a preview's join link. Launch data is
-- serialized the same way storybookPreviewUrl serializes it, and the backend
-- percent-encodes it with the same rules as percentEncode. Together they make
-- scanning the code open the same link the comment prints. The backend rejects
-- launch data over 200 bytes, and the comment then shows a broken image.
local function storybookQrCodeUrl(placeId: number, launchData: string?): string
	local url = `{QR_CODE_BASE_URL}/{placeId}.svg`

	if launchData then
		assert(launchData:match("^%s*{"), "launch data must be a JSON object")
		local decodedLaunchData = json.deserialize(launchData) :: json.Object
		url ..= `?launchData={percentEncode(json.serialize(decodedLaunchData))}`
	end

	return url
end

return storybookQrCodeUrl
