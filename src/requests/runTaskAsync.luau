local json = require("@std/json")

local createTaskAsync = require("@root/requests/luau-execution/createTaskAsync")
local getTaskLogsAsync = require("@root/requests/luau-execution/getTaskLogsAsync")
local types = require("@root/types")
local waitForTaskCompletion = require("@root/requests/luau-execution/waitForTaskCompletion")

type LuauExecutionContext = types.LuauExecutionContext

-- Run a Luau script in the place via the Open Cloud Luau Execution API. Globals
-- are injected as `_G` entries at the top of the script (matching how the script
-- bodies in src/tasks read them). The last JSON object a script prints is parsed
-- and returned, so tasks can hand structured results back to the CLI.
local function runTaskAsync(
	script: string,
	globals: { [string]: string | number | boolean },
	luauExecutionContext: LuauExecutionContext
): unknown
	local parts = {}
	for key, value in globals do
		table.insert(parts, `_G["{key}"]={json.serialize(value)};`)
	end
	local entryScript = table.concat(parts) .. script

	local createdTask = createTaskAsync(luauExecutionContext, entryScript)
	local completedTask = waitForTaskCompletion(luauExecutionContext, createdTask.path)

	local logs = getTaskLogsAsync(luauExecutionContext, createdTask.path)
	for _, message in logs do
		print(message)
	end

	if completedTask.state ~= "COMPLETE" then
		local taskError = completedTask.error
		if taskError then
			error(`Luau execution task {completedTask.state}: {taskError.code} - {taskError.message}`, 0)
		end
		error(`Luau execution task {completedTask.state}`, 0)
	end

	local lastLine
	for _, message in logs do
		if message:match("%S") then
			lastLine = message
		end
	end

	if lastLine then
		local parseOk, result = pcall(json.deserialize, lastLine)
		if parseOk then
			return result
		end
		return lastLine
	end

	return nil
end

return runTaskAsync
