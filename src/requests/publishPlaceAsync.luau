local fs = require("@std/fs")
local path = require("@std/path")

local fetch = require("@root/requests/fetch")

local function publishPlaceAsync(universeId: number, placeId: number, rbxlPath: path.Pathlike, apiKey: string)
	local url = `https://apis.roblox.com/universes/v1/{universeId}/places/{placeId}/versions?versionType=Published`

	local ok, err = pcall(function()
		fetch(url, {
			method = "POST",
			headers = {
				["x-api-key"] = apiKey,
				["Content-Type"] = "model/x-rbxl",
			},
			body = fs.readFileToString(rbxlPath),
		})
	end)

	if not ok then
		-- A 409 Conflict here reports that the server is "busy", but in practice it
		-- almost always means the place is currently open in Roblox Studio, which holds
		-- a lock on it. Surface that as the likely cause instead of the misleading message.
		if typeof(err) == "string" and (string.find(err, "409", 1, true) or string.find(err, "Conflict", 1, true)) then
			error(
				`Failed to publish to place {placeId}: Roblox returned a 409 Conflict. This usually means the place `
					.. `is open in Roblox Studio, which locks it against publishing. Close the place in Studio and try `
					.. `again.\n\nOriginal error: {err}`,
				2
			)
		end

		error(err, 2)
	end
end

return publishPlaceAsync
