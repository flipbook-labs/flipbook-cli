local resolveOrCreatePlaceScript = require("@root/tasks/resolve-or-create-place")
local runTaskAsync = require("@root/requests/runTaskAsync")

local function resolvePlaceIdAsync(
	placeName: string,
	apiKey: string,
	luauExecutionContext: {
		universeId: number,
		placeId: number?,
	}
): (number, boolean)
	local result: { placeId: string, created: boolean? } = runTaskAsync(resolveOrCreatePlaceScript, {
		DESIRED_NAME = placeName,
	}, luauExecutionContext.universeId, luauExecutionContext.placeId, apiKey)

	assert(result and result.placeId, "failed to resolve or create place")
	return assert(tonumber(result.placeId), "placeId from task was not a valid number"), result.created == true
end

return resolvePlaceIdAsync
