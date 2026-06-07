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

	if ok then
		return
	end

	-- Roblox answers a publish request with 409 Conflict when the place is locked,
	-- which is nearly always because it's still open in Studio. The raw status line
	-- doesn't say that, so point the user at the actual fix.
	-- fetch formats the failure as "{status} {body} when attempting to ...", so the
	-- status leads the string. Match "409 " (with the trailing space) so a place or
	-- universe id that happens to contain "409" in the URL can't trigger a false match.
	local message = tostring(err)
	if message:find("409 ") then
		error(
			`Could not publish place {placeId}: Roblox returned 409 Conflict. The place is probably open in `
				.. `Roblox Studio, which locks it for publishing — close it there and run this again.\n\n{message}`,
			-- fetch already baked a location into the message; level 0 avoids stacking another on top.
			0
		)
	end

	error(message, 0)
end

return publishPlaceAsync
