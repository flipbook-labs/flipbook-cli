local json = require("@std/json")

local constants = require("@root/requests/luau-execution/constants")
local fetch = require("@root/requests/fetch")
local types = require("@root/types")

type LuauExecutionContext = types.LuauExecutionContext

local function createTaskAsync(ctx: LuauExecutionContext, script: string): { path: string }
	local response =
		fetch(`{constants.CLOUD_BASE}/universes/{ctx.universeId}/places/{ctx.placeId}/luau-execution-session-tasks`, {
			method = "POST",
			headers = {
				["x-api-key"] = ctx.apiKey,
				["content-type"] = "application/json",
			},
			body = json.serialize({
				script = script,
				timeout = "300s",
			}),
		})

	local obj = json.asObject(response)
	if obj then
		return { path = obj.path :: string }
	end
	error("Malformed response when creating a task")
end

return createTaskAsync
