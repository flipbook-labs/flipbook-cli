local FlipbookBatteries = require("@pkg/flipbook-batteries@v0.9.0")
local fs = require("@std/fs")
local path = require("@std/path")
local system = require("@std/system")

local config = require("@root/config")

local run = FlipbookBatteries.run

local function runTask(
	script: string,
	globals: { [string]: string | number },
	universeId: string,
	placeId: string,
	apiKey: string
)
	local parts = {}
	for key, value in globals do
		table.insert(parts, key .. "=" .. tostring(value))
	end

	local scriptPath = tostring(path.join(tostring(system.tmpdir()), "flipbook-task-" .. os.time() .. ".luau"))
	fs.writeStringToFile(scriptPath, script)

	local ok, err = pcall(run, config.rocaleCmd, {
		"run",
		"--script",
		scriptPath,
		"--universeId",
		universeId,
		"--placeId",
		placeId,
		"--lua.globals",
		table.concat(parts, ","),
	}, { env = { ROBLOX_API_KEY = apiKey } })

	fs.remove(scriptPath)

	if not ok then
		error(err, 0)
	end
end

return runTask
