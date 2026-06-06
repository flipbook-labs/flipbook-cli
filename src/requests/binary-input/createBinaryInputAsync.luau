local json = require("@std/json")

local fetch = require("@root/requests/fetch")
local types = require("@root/types")

type LuauExecutionContext = types.LuauExecutionContext

local CLOUD_BASE = "https://apis.roblox.com/cloud/v2"

-- Reserve a binary-input slot scoped to the universe. Returns the resource path
-- to reference from the task plus a signed URL to upload the bytes to.
local function createBinaryInputAsync(ctx: LuauExecutionContext, byteSize: number): { path: string, uploadUri: string }
	return fetch(`{CLOUD_BASE}/universes/{ctx.universeId}/luau-execution-session-task-binary-inputs`, {
		method = "POST",
		headers = {
			["x-api-key"] = ctx.apiKey,
			["content-type"] = "application/json",
		},
		body = json.serialize({ size = byteSize }),
	}) :: any
end

return createBinaryInputAsync
