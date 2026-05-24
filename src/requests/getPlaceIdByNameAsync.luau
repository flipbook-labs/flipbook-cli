local json = require("@std/json")

local fetch = require("@root/requests/fetch")
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

		local body = json.asObject(fetch(
			`https://develop.roblox.com/v1/universes/{universeId}/places?{table.concat(query, "&")}`,
			{
				headers = {
					["x-api-key"] = apiKey,
				},
			}
		))
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
