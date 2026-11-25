local createPlaceAsync = require("@root/requests/createPlaceAsync")
local getPlaceIdByNameAsync = require("@root/requests/getPlaceIdByNameAsync")
local types = require("@root/types")

local function getOrCreatePlaceByNameAsync(
	universeId: number,
	placeName: string,
	luauExecutionContext: types.LuauExecutionContext
): number
	local resolvedPlaceId = getPlaceIdByNameAsync(universeId, placeName, luauExecutionContext.apiKey)
	if resolvedPlaceId then
		return resolvedPlaceId
	end

	return createPlaceAsync(universeId, placeName, luauExecutionContext)
end

return getOrCreatePlaceByNameAsync
