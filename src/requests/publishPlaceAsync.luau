local fs = require("@std/fs")
local path = require("@std/path")

local fetch = require("@root/requests/fetch")

local function publishPlaceAsync(universeId: number, placeId: number, rbxlPath: path.Pathlike, apiKey: string)
	local content = fs.readFileToString(rbxlPath)

	fetch(`https://apis.roblox.com/universes/v1/{universeId}/places/{placeId}/versions?versionType=Published`, {
		method = "POST",
		headers = {
			["x-api-key"] = apiKey,
			["Content-Type"] = "model/x-rbxl",
		},
		body = content,
	})
end

return publishPlaceAsync
