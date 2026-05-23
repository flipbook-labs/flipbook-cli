local FlipbookBatteries = require("@pkg/flipbook-batteries@v0.9.0")
local fs = require("@std/fs")
local json = require("@std/json")
local path = require("@std/path")
local system = require("@std/system")

local config = require("@root/config")
local types = require("@root/types")

local run = FlipbookBatteries.run

type LuauExecutionContext = types.LuauExecutionContext

local function runTaskAsync(
	script: string,
	globals: { [string]: string | number | boolean },
	luauExecutionContext: LuauExecutionContext
): any
	local parts = {}
	for key, value in globals do
		table.insert(parts, key .. "=" .. tostring(value))
	end

	local scriptPath = tostring(path.join(system.tmpdir(), `flipbook-task-{os.time()}.luau`))
	fs.writeStringToFile(scriptPath, script)

	local cliArgs = {
		"run",
		"--script",
		scriptPath,
		"--universeId",
		luauExecutionContext.universeId,
	}
	if luauExecutionContext.placeId then
		table.insert(cliArgs, "--placeId")
		table.insert(cliArgs, luauExecutionContext.placeId)
	end
	table.insert(cliArgs, "--lua.globals")
	table.insert(cliArgs, table.concat(parts, ","))

	local output
	local ok, err = pcall(function()
		output = run(config.rocaleCmd, cliArgs :: { any }, {
			env = { ROBLOX_API_KEY = luauExecutionContext.apiKey },
			captureOutput = true,
		})
	end)

	fs.remove(scriptPath)

	if not ok then
		error(err, 0)
	end

	if output and output ~= "" then
		local parseOk, result = pcall(json.deserialize, output)
		if parseOk then
			return result
		end
	end

	return nil
end

return runTaskAsync
