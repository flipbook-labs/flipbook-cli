local json = require("@std/json")

local fetch = require("@root/requests/fetch")
local types = require("@root/types")

type LuauExecutionContext = types.LuauExecutionContext

local CLOUD_BASE = "https://apis.roblox.com/cloud/v2"

local function createTaskAsync(ctx: LuauExecutionContext, script: string, binaryInputPath: string?): { path: string }
	local body: { [string]: any } = {
		script = script,
		timeout = "300s",
	}
	if binaryInputPath then
		body.binaryInput = binaryInputPath
	end

	return fetch(`{CLOUD_BASE}/universes/{ctx.universeId}/places/{ctx.placeId}/luau-execution-session-tasks`, {
		method = "POST",
		headers = {
			["x-api-key"] = ctx.apiKey,
			["content-type"] = "application/json",
		},
		body = json.serialize(body),
	}) :: any
end

return createTaskAsync
