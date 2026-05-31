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
): unknown
	local parts = {}
	for key, value in globals do
		table.insert(parts, `{key}="{value}"`)
	end

	local scriptPath = tostring(path.join(system.tmpdir(), `flipbook-task-{os.time()}.luau`))
	fs.writeStringToFile(scriptPath, script)

	local output
	local ok, err = xpcall(function()
		output = run(config.rocaleCmd, {
			"run",
			"--script",
			scriptPath,
			"--universeId",
			luauExecutionContext.universeId,
			"--placeId",
			luauExecutionContext.placeId,
			"--lua.globals",
			table.concat(parts, ","),
		}, {
			env = {
				ROBLOX_API_KEY = luauExecutionContext.apiKey,
			},
			stdio = "default",
		})
		return nil
	end, function(message: string): string
		return debug.traceback(message, 2)
	end)

	fs.remove(scriptPath)

	if not ok then
		error(err, 0)
	end

	if output and output ~= "" then
		local lastLine
		for line in output:gmatch("[^\n]+") do
			if line:match("%S") then
				lastLine = line
			end
		end

		if lastLine then
			local parseOk, result = pcall(json.deserialize, lastLine)
			if parseOk then
				return result
			end
			return lastLine
		end
	end

	return nil
end

return runTaskAsync
