local fs = require("@std/fs")
local json = require("@std/json")

local createBinaryInputAsync = require("@root/requests/binary-input/createBinaryInputAsync")
local createTaskAsync = require("@root/requests/binary-input/createTaskAsync")
local getTaskLogsAsync = require("@root/requests/binary-input/getTaskLogsAsync")
local types = require("@root/types")
local uploadBinaryFileAsync = require("@root/requests/binary-input/uploadBinaryFileAsync")
local waitForTaskCompletion = require("@root/requests/binary-input/waitForTaskCompletion")

type LuauExecutionContext = types.LuauExecutionContext

export type RunTaskOptions = {
	-- Path to a file uploaded as the task's binary input. The bytes arrive in
	-- the script as `({ ... })[1].BinaryInput`, a buffer ready for
	-- SerializationService:DeserializeInstancesAsync.
	binaryInputPath: string?,
}

type Globals = { [string]: string | number | boolean }

-- Run a Luau script in the place via the Open Cloud Luau Execution API. Globals
-- are injected as `_G` entries at the top of the script (matching how the script
-- bodies in src/tasks read them). The last JSON object a script prints is parsed
-- and returned, so tasks can hand structured results back to the CLI.
local function runTaskAsync(
	script: string,
	globals: Globals,
	luauExecutionContext: LuauExecutionContext,
	options: RunTaskOptions?
): unknown
	local assignments = {}
	for key, value in globals do
		table.insert(assignments, `_G["{key}"]={json.serialize(value)};`)
	end
	local entryScript = table.concat(assignments) .. script

	local binaryInputPath = if options then options.binaryInputPath else nil
	local binaryInputResourcePath: string? = nil
	if binaryInputPath then
		local contents = fs.readFileToString(binaryInputPath)
		local binaryInput = createBinaryInputAsync(luauExecutionContext, #contents)
		uploadBinaryFileAsync(binaryInput.uploadUri, contents)
		binaryInputResourcePath = binaryInput.path
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
