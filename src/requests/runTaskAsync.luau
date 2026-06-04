local fs = require("@std/fs")
local json = require("@std/json")
local net = require("@std/net")
local task = require("@std/task")

local types = require("@root/types")

type LuauExecutionContext = types.LuauExecutionContext

export type RunTaskOptions = {
	-- Path to a file uploaded as the task's binary input. The bytes arrive in
	-- the script as `({ ... })[1].BinaryInput`, a buffer ready for
	-- SerializationService:DeserializeInstancesAsync.
	binaryInputPath: string?,
}

local CLOUD_BASE = "https://apis.roblox.com/cloud/v2"
local POLL_INTERVAL_SECONDS = 2

type Globals = { [string]: string | number | boolean }

local function request(
	url: string,
	options: { method: string, headers: { [string]: string }?, body: string? }
): net.Response
	local response = net.request(url, {
		method = options.method,
		headers = options.headers,
		body = options.body,
	})

	if not response.ok then
		error(`{response.status} when attempting to {options.method} {url}: {response.body}`, 0)
	end

	return response
end

-- Reserve a binary-input slot scoped to the universe. Returns the resource path
-- to reference from the task plus a signed URL to upload the bytes to.
local function createBinaryInput(ctx: LuauExecutionContext, byteSize: number): { path: string, uploadUri: string }
	local response = request(`{CLOUD_BASE}/universes/{ctx.universeId}/luau-execution-session-task-binary-inputs`, {
		method = "POST",
		headers = {
			["x-api-key"] = ctx.apiKey,
			["content-type"] = "application/json",
		},
		body = json.serialize({ size = byteSize }),
	})

	return json.deserialize(response.body) :: any
end

-- Upload the raw bytes to the signed URL from createBinaryInput. No API key is
-- sent here; authorization is baked into the URL.
local function uploadBinaryFile(uploadUri: string, contents: string)
	request(uploadUri, {
		method = "PUT",
		headers = {
			["content-type"] = "application/octet-stream",
		},
		body = contents,
	})
end

local function createTask(ctx: LuauExecutionContext, script: string, binaryInputPath: string?): { path: string }
	local body: { [string]: any } = {
		script = script,
		timeout = "300s",
	}
	if binaryInputPath then
		body.binaryInput = binaryInputPath
	end

	local response =
		request(`{CLOUD_BASE}/universes/{ctx.universeId}/places/{ctx.placeId}/luau-execution-session-tasks`, {
			method = "POST",
			headers = {
				["x-api-key"] = ctx.apiKey,
				["content-type"] = "application/json",
			},
			body = json.serialize(body),
		})

	return json.deserialize(response.body) :: any
end

type TaskResult = {
	state: string,
	error: { code: string, message: string }?,
}

local function pollTaskCompletion(ctx: LuauExecutionContext, taskPath: string): TaskResult
	while true do
		local response = request(`{CLOUD_BASE}/{taskPath}`, {
			method = "GET",
			headers = { ["x-api-key"] = ctx.apiKey },
		})

		local result = json.deserialize(response.body) :: any
		if result.state ~= "PROCESSING" and result.state ~= "QUEUED" then
			return result
		end

		task.wait(POLL_INTERVAL_SECONDS)
	end
end

local function getTaskLogs(ctx: LuauExecutionContext, taskPath: string): { string }
	local response = request(`{CLOUD_BASE}/{taskPath}/logs`, {
		method = "GET",
		headers = { ["x-api-key"] = ctx.apiKey },
	})

	local body = json.deserialize(response.body) :: any
	local sessions = body.luauExecutionSessionTaskLogs
	if sessions and sessions[1] then
		return sessions[1].messages or {}
	end
	return {}
end

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
		local binaryInput = createBinaryInput(luauExecutionContext, #contents)
		uploadBinaryFile(binaryInput.uploadUri, contents)
		binaryInputResourcePath = binaryInput.path
	end

	local createdTask = createTask(luauExecutionContext, entryScript, binaryInputResourcePath)
	local completedTask = pollTaskCompletion(luauExecutionContext, createdTask.path)

	local logs = getTaskLogs(luauExecutionContext, createdTask.path)
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
