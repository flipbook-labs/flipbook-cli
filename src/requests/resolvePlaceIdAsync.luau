local json = require("@std/json")

local resolveOrCreatePlaceScript = require("@root/tasks/resolve-or-create-place")
local runTaskAsync = require("@root/requests/runTaskAsync")
local types = require("@root/types")

type LuauExecutionContext = types.LuauExecutionContext

local function resolvePlaceIdAsync(placeName: string, luauExecutionContext: LuauExecutionContext): (number, boolean)
	local result = runTaskAsync(resolveOrCreatePlaceScript, {
		DESIRED_NAME = placeName,
	}, luauExecutionContext)

	local body = json.deserialize(result.body)
	assert(type(body) == "table", "task did not return a table")
	assert(body.placeId, "failed to resolve or create place")
	assert(body.created ~= nil, "task did not return created field")
	return assert(tonumber(body.placeId), "placeId from task was not a valid number"), body.created == true
end

return resolvePlaceIdAsync
