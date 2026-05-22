local FlipbookBatteries = require("@pkg/flipbook-batteries@v0.9.0")
local path = require("@std/path")

local config = require("@root/config")

local run = FlipbookBatteries.run

local function publishPlace(universeId: number, placeId: number, rbxlPath: path.Pathlike, apiKey: string)
	local url = `https://apis.roblox.com/universes/v1/{universeId}/places/{placeId}/versions?versionType=Published`
	run(config.curlCmd, {
		"--fail-with-body",
		"-sS",
		"-X",
		"POST",
		"-H",
		`x-api-key: {apiKey}`,
		"-H",
		"Content-Type: application/octet-stream",
		"--data-binary",
		`@{rbxlPath}`,
		url,
	}, {
		stdio = "default",
	})
end

return publishPlace
