local json = require("@std/json")
local net = require("@std/net")

local percentEncode = require("@root/percentEncode")

local function getPlaceIdByNameAsync(universeId: number, placeName: string, apiKey: string): number?
	local cursor: string? = nil

	while true do
		local query: { string } = {
			"limit=100",
			"isUniverseCreation=true",
		}
		if cursor then
			table.insert(query, `cursor={percentEncode(cursor)}`)
		end

		local response =
			net.request(`https://develop.roblox.com/v1/universes/{universeId}/places?{table.concat(query, "&")}`, {
				method = "GET",
				headers = {
					["x-api-key"] = apiKey,
				},
			})

		if response.status >= 400 then
			error(`failed to list places for universe {universeId} ({response.status}): {response.body}`)
		end

		local body = json.asObject(json.deserialize(response.body))
		if not body then
			return nil
		end

		local data = body.data
		if type(data) == "table" then
			for _, place in data do
				if place.name == placeName then
					return place.id
				end
			end
		end

		local nextCursor = body.nextPageCursor
		if type(nextCursor) ~= "string" or nextCursor == "" then
			return nil
		end
		cursor = nextCursor
	end
end

return getPlaceIdByNameAsync
