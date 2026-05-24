local createPlaceScript = require("@root/tasks/createPlace")
local runTaskAsync = require("@root/requests/runTaskAsync")
local types = require("@root/types")

type LuauExecutionContext = types.LuauExecutionContext

local function createPlaceAsync(
	universeId: number,
	placeName: string,
	luauExecutionContext: LuauExecutionContext
): number
	print(`Creating new place {placeName} in universe {universeId}...`)

	local result = runTaskAsync(createPlaceScript, {
		DESIRED_NAME = placeName,
	}, luauExecutionContext)

	assert(type(result) == "table", "expected task result to be a table, got " .. tostring(result))
	assert(result.placeId, "failed to resolve or create place")

	local placeId = assert(tonumber(result.placeId), "placeId from task was not a valid number")

	print(`Created new place with ID {placeId} for {placeName}`)
	return placeId
end

return createPlaceAsync
