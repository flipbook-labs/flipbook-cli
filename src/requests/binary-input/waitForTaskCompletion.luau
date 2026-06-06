local task = require("@std/task")

local constants = require("@root/requests/binary-input/constants")
local fetch = require("@root/requests/fetch")
local types = require("@root/types")

type LuauExecutionContext = types.LuauExecutionContext

export type TaskResult = {
	state: string,
	error: { code: string, message: string }?,
}

local function waitForTaskCompletion(ctx: LuauExecutionContext, taskPath: string): TaskResult
	while true do
		local result = fetch(`{constants.CLOUD_BASE}/{taskPath}`, {
			method = "GET",
			headers = { ["x-api-key"] = ctx.apiKey },
		})

		if result.state ~= "PROCESSING" and result.state ~= "QUEUED" then
			return result
		end

		task.wait(constants.POLL_INTERVAL_SECONDS)
	end
end

return waitForTaskCompletion
