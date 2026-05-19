local FlipbookBatteries = require("@pkg/flipbook-batteries@v0.9.0")

local run = FlipbookBatteries.run

local function runTask(
	taskPath: string,
	globals: { [string]: string | number },
	universeId: string,
	placeId: string,
	apiKey: string
)
	local parts = {}
	for key, value in globals do
		table.insert(parts, key .. "=" .. tostring(value))
	end

	run("rocale", {
		"run",
		"--script",
		taskPath,
		"--universeId",
		universeId,
		"--placeId",
		placeId,
		"--lua.globals",
		table.concat(parts, ","),
	}, { env = { ROBLOX_API_KEY = apiKey } })
end

return runTask
