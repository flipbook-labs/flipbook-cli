local task = require("@std/task")

local LuauExecution = require("@lpm/luau-execution@v0.2.0")
local OpenApiRuntime = require("@lpm/openapi-runtime@v0.1.0")
local parseTaskPath = require("@root/requests/binary-input/parseTaskPath")

-- How long to wait between task-status polls.
local POLL_INTERVAL_SECONDS = 2

-- Polls a task until it leaves the queue and finishes running, then returns it.
local function waitForTaskCompletion(
	client: OpenApiRuntime.Client,
	taskIds: parseTaskPath.TaskIds
): LuauExecution.LuauExecutionSessionTask
	while true do
		local current = LuauExecution.getLuauExecutionSessionTask(client, {
			universe_id = taskIds.universe_id,
			place_id = taskIds.place_id,
			version_id = taskIds.version_id,
			luau_execution_session_id = taskIds.luau_execution_session_id,
			task_id = taskIds.task_id,
		})
		if current.state ~= "PROCESSING" and current.state ~= "QUEUED" then
			return current
		end

		task.wait(POLL_INTERVAL_SECONDS)
	end
end

return waitForTaskCompletion
