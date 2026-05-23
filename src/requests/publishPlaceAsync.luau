local fs = require("@std/fs")
local path = require("@std/path")

local fetch = require("@root/requests/fetch")

local function publishPlaceAsync(universeId: number, placeId: number, rbxlPath: path.Pathlike, apiKey: string)
	local url = `https://apis.roblox.com/universes/v1/{universeId}/places/{placeId}/versions?versionType=Published`

	fetch(url, {
		method = "POST",
		headers = {
			["x-api-key"] = apiKey,
			["Content-Type"] = "application/octet-stream",
		},
		body = fs.readFileToString(tostring(rbxlPath)),
	})
end

return publishPlaceAsync
