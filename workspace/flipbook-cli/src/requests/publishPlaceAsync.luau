local fs = require("@std/fs")
local path = require("@std/path")

local OpenApiRuntime = require("@lpm/openapi-runtime@v0.1.0")
local Places = require("@lpm/places@v0.2.0")
local createOpenCloudClient = require("@root/requests/createOpenCloudClient")

local function publishPlaceAsync(universeId: number, placeId: number, rbxlPath: path.Pathlike, apiKey: string)
	local ok, err = pcall(Places.createPlaceVersionApiKey, createOpenCloudClient(apiKey), {
		universeId = universeId,
		placeId = placeId,
		versionType = "Published",
		body = fs.readFileToString(rbxlPath),
	})

	if ok then
		return
	end

	-- Roblox answers a publish request with 409 Conflict when the place is locked,
	-- which is nearly always because it's still open in Studio. The raw status line
	-- doesn't say that, so point the user at the actual fix.
	local failure: unknown = err
	if type(failure) == "table" and (failure :: OpenApiRuntime.HttpError).status == 409 then
		error(
			`Could not publish place {placeId}: Roblox returned 409 Conflict. The place is probably open in `
				.. `Roblox Studio, which locks it for publishing — close it there and run this again.\n\n{failure}`,
			0
		)
	end

	error(tostring(failure), 0)
end

return publishPlaceAsync
