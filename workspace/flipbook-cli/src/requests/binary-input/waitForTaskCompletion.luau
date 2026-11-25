local json = require("@std/json")
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
		local body = fetch(`{constants.CLOUD_BASE}/{taskPath}`, {
			method = "GET",
			headers = { ["x-api-key"] = ctx.apiKey },
		})

		local obj = json.asObject(body)
		if obj then
			local state = obj.state :: string
			if state ~= "PROCESSING" and state ~= "QUEUED" then
				local err = json.asObject(obj.error)
				return {
					state = state,
					error = if err
						then {
							code = err.code :: string,
							message = err.message :: string,
						}
						else nil,
				}
			end
		end

		task.wait(constants.POLL_INTERVAL_SECONDS)
	end
end

return waitForTaskCompletion
