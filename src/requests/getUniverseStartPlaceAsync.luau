local fetch = require("@root/requests/fetch")

local function getUniverseStartPlaceAsync(universeId: number, apiKey: string): number
	local body = fetch(`https://develop.roblox.com/v1/universes/{universeId}/places`, {
		headers = {
			["x-api-key"] = apiKey,
		},
	}) :: any

	-- We choose the first place in the list and assume that's the start place.
	-- We really just need a placeId to use as the base for Luau Execution.
	-- This placeId won't get directly written to, just used as the task host.
	if type(body) == "table" and type(body.data) == "table" then
		local data = body.data
		if #data > 0 then
			local first = data[1]
			return first.id
		end
	end

	error(`failed to find the start place for universe {universeId}`)
end

return getUniverseStartPlaceAsync
