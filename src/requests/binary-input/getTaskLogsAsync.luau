local json = require("@std/json")

local constants = require("@root/requests/binary-input/constants")
local fetch = require("@root/requests/fetch")
local types = require("@root/types")

type LuauExecutionContext = types.LuauExecutionContext

local function getTaskLogsAsync(ctx: LuauExecutionContext, taskPath: string): { string }
	local body = fetch(`{constants.CLOUD_BASE}/{taskPath}/logs`, {
		method = "GET",
		headers = { ["x-api-key"] = ctx.apiKey },
	})

	local obj = json.asObject(body)
	if obj then
		local sessions = json.asArray(obj.luauExecutionSessionTaskLogs)
		local session = if sessions and sessions[1] then json.asObject(sessions[1]) else nil
		if session then
			return json.asArray(session.messages) :: { string } or {}
		end
	end
	return {}
end

return getTaskLogsAsync
