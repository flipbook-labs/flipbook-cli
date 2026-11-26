local fs = require("@std/fs")
local json = require("@std/json")
local path = require("@std/path")

local LuauExecution = require("@lpm/open-cloud-luau-execution@v0.2.0")
local createOpenCloudClient = require("@root/requests/createOpenCloudClient")
local getTaskLogsAsync = require("@root/requests/binary-input/getTaskLogsAsync")
local parseTaskPath = require("@root/requests/binary-input/parseTaskPath")
local types = require("@root/types")
local uploadBinaryFileAsync = require("@root/requests/binary-input/uploadBinaryFileAsync")
local waitForTaskCompletion = require("@root/requests/binary-input/waitForTaskCompletion")

type LuauExecutionContext = types.LuauExecutionContext

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
	local client = createOpenCloudClient(luauExecutionContext.apiKey)
	local universeId = tostring(luauExecutionContext.universeId)

	local parts = {}
	for key, value in globals do
		table.insert(parts, `_G["{key}"]={json.serialize(value)};`)
	end
	local entryScript = table.concat(parts) .. script

	local binaryInputResourcePath: string? = nil
	if binaryInput then
		local contents = fs.readFileToString(binaryInput)
		local reservedBinaryInput = LuauExecution.createLuauExecutionSessionTaskBinaryInput(client, {
			universe_id = universeId,
			body = {
				size = #contents,
			},
		})
		uploadBinaryFileAsync(assert(reservedBinaryInput.uploadUri, "Binary input has no upload URI"), contents)
		binaryInputResourcePath = assert(reservedBinaryInput.path, "Binary input has no resource path")
	end

	local createdTask = LuauExecution.createLuauExecutionSessionTaskUsingUniverses(client, {
		universe_id = universeId,
		place_id = tostring(luauExecutionContext.placeId),
		body = {
			script = entryScript,
			timeout = "300s",
			binaryInput = binaryInputResourcePath,
		},
	})
	local taskIds = parseTaskPath(assert(createdTask.path, "Created task has no resource path"))
	local completedTask = waitForTaskCompletion(client, taskIds)

	local logs = getTaskLogsAsync(client, taskIds)
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
