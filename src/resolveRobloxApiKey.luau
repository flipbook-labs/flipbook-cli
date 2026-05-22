local process = require("@std/process")

local function resolveRobloxApiKey(cliValue: string?): string
	return cliValue or assert(process.env.ROBLOX_API_KEY, "ROBLOX_API_KEY is required when not passing --api-key")
end

return resolveRobloxApiKey
