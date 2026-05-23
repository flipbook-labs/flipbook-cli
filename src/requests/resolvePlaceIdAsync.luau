local json = require("@std/json")

local resolveOrCreatePlaceScript = require("@root/tasks/resolve-or-create-place")
local runTaskAsync = require("@root/requests/runTaskAsync")
local types = require("@root/types")

type LuauExecutionContext = types.LuauExecutionContext

local function resolvePlaceIdAsync(placeName: string, luauExecutionContext: LuauExecutionContext): number
	print(`Resolving place ID for {placeName}...`)

	local result = runTaskAsync(resolveOrCreatePlaceScript, {
		DESIRED_NAME = placeName,
	}, luauExecutionContext)

	assert(type(result) == "table", "expected task result to be a table, got " .. tostring(result))
	assert(result.placeId, "failed to resolve or create place")
	assert(result.created ~= nil, "task did not return created field")

	local wasCreated = result.created == true

	local placeId = assert(tonumber(result.placeId), "placeId from task was not a valid number")

	if wasCreated then
		print(`Created new place with ID {placeId} for {placeName}`)
	else
		print(`Resolved place ID {placeId} for {placeName}`)
	end
	return placeId
end

return resolvePlaceIdAsync
