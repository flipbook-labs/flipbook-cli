local LuauExecution = require("@lpm/luau-execution@v0.2.0")
local OpenApiRuntime = require("@lpm/openapi-runtime@v0.1.0")
local parseTaskPath = require("@root/requests/binary-input/parseTaskPath")

-- Returns each message the task printed, in order.
local function getTaskLogsAsync(client: OpenApiRuntime.Client, taskIds: parseTaskPath.TaskIds): { string }
	local response = LuauExecution.listLuauExecutionSessionTaskLogs(client, {
		universe_id = taskIds.universe_id,
		place_id = taskIds.place_id,
		version_id = taskIds.version_id,
		luau_execution_session_id = taskIds.luau_execution_session_id,
		task_id = taskIds.task_id,
	})
	local logs = response.luauExecutionSessionTaskLogs
	local first = if logs then logs[1] else nil
	return if first and first.messages then first.messages else {}
end

return getTaskLogsAsync
