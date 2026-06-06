local task = require("@std/task")

local fetch = require("@root/requests/fetch")
local types = require("@root/types")

type LuauExecutionContext = types.LuauExecutionContext

local CLOUD_BASE = "https://apis.roblox.com/cloud/v2"
local POLL_INTERVAL_SECONDS = 2

export type TaskResult = {
	state: string,
	error: { code: string, message: string }?,
}

local function waitForTaskCompletion(ctx: LuauExecutionContext, taskPath: string): TaskResult
	while true do
		local result = fetch(`{CLOUD_BASE}/{taskPath}`, {
			method = "GET",
			headers = { ["x-api-key"] = ctx.apiKey },
		}) :: any

		if result.state ~= "PROCESSING" and result.state ~= "QUEUED" then
			return result
		end

		task.wait(POLL_INTERVAL_SECONDS)
	end
end

return waitForTaskCompletion
