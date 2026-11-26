local OpenApiLuteTransport = require("@lpm/openapi-lute-transport@v0.1.0")
local OpenApiRuntime = require("@lpm/openapi-runtime@v0.1.0")

-- Builds the client the generated Open Cloud functions send requests through,
-- authenticated with the user's API key.
local function createOpenCloudClient(apiKey: string): OpenApiRuntime.Client
	return OpenApiRuntime.createClient({
		baseUrl = "https://apis.roblox.com",
		transport = OpenApiLuteTransport,
		headers = {
			["x-api-key"] = apiKey,
		},
	})
end

return createOpenCloudClient
