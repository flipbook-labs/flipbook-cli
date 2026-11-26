--[[
	The IDs in a Luau execution task's resource path, keyed the way the generated
	Luau Execution functions take them. Looking a task up or reading its logs
	takes each ID separately rather than the whole path.
]]
export type TaskIds = {
	universe_id: string,
	place_id: string,
	version_id: string,
	luau_execution_session_id: string,
	task_id: string,
}

-- Splits a task path such as
-- `universes/1/places/2/versions/3/luau-execution-sessions/4/tasks/5` into its
-- IDs.
local function parseTaskPath(taskPath: string): TaskIds
	local universeId, placeId, versionId, sessionId, taskId = taskPath:match(
		"^universes/([^/]+)/places/([^/]+)/versions/([^/]+)/luau%-execution%-sessions/([^/]+)/tasks/([^/]+)$"
	)
	if not (universeId and placeId and versionId and sessionId and taskId) then
		error(`Unexpected Luau execution task path: {taskPath}`, 0)
	end

	return {
		universe_id = universeId,
		place_id = placeId,
		version_id = versionId,
		luau_execution_session_id = sessionId,
		task_id = taskId,
	}
end

return parseTaskPath
