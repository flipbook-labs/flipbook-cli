local fs = require("@std/fs")
local json = require("@std/json")
local path = require("@std/path")

local createBinaryInputAsync = require("@root/requests/binary-input/createBinaryInputAsync")
local createTaskAsync = require("@root/requests/binary-input/createTaskAsync")
local getTaskLogsAsync = require("@root/requests/binary-input/getTaskLogsAsync")
local types = require("@root/types")
local uploadBinaryFileAsync = require("@root/requests/binary-input/uploadBinaryFileAsync")
local waitForTaskCompletion = require("@root/requests/binary-input/waitForTaskCompletion")

type LuauExecutionContext = types.LuauExecutionContext

export type RunTaskOptions = {}

-- Run a Luau script in the place via the Open Cloud Luau Execution API. Globals
-- are injected as `_G` entries at the top of the script (matching how the script
-- bodies in src/tasks read them). The last JSON object a script prints is parsed
-- and returned, so tasks can hand structured results back to the CLI.
local function runTaskAsync(
	script: string,
	globals: { [string]: string | number | boolean },
	luauExecutionContext: LuauExecutionContext,
	-- Path to a file that will be accessible inside the task script as a
	-- buffer. Usage: `({ ... })[1].BinaryInput`
	binaryInput: path.Pathlike?
): unknown
	local parts = {}
	for key, value in globals do
		table.insert(parts, `_G["{key}"]={json.serialize(value)};`)
	end
	local entryScript = table.concat(parts) .. script

	local binaryInputResourcePath: string? = nil
	if binaryInput then
		local contents = fs.readFileToString(binaryInput)
		local reservedBinaryInput = createBinaryInputAsync(luauExecutionContext, #contents)
		uploadBinaryFileAsync(reservedBinaryInput.uploadUri, contents)
		binaryInputResourcePath = reservedBinaryInput.path
	end

	local createdTask = createTaskAsync(luauExecutionContext, entryScript, binaryInputResourcePath)
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
