local fetch = require("@root/requests/fetch")
local types = require("@root/types")

type LuauExecutionContext = types.LuauExecutionContext

local CLOUD_BASE = "https://apis.roblox.com/cloud/v2"

local function getTaskLogsAsync(ctx: LuauExecutionContext, taskPath: string): { string }
	local body = fetch(`{CLOUD_BASE}/{taskPath}/logs`, {
		method = "GET",
		headers = { ["x-api-key"] = ctx.apiKey },
	}) :: any

	local sessions = body.luauExecutionSessionTaskLogs
	if sessions and sessions[1] then
		return sessions[1].messages or {}
	end
	return {}
end

return getTaskLogsAsync
