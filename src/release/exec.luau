local process = require("@std/process")

export type RunResult = process.ProcessResult
export type RunOptions = process.ProcessRunOptions

-- Run a command, returning the raw result without asserting on the exit code.
-- Use this when a non-zero exit is expected and meaningful (e.g. probing for a
-- tag or release that may not exist).
local function run(args: { string }, options: RunOptions?): RunResult
	return process.run(args, options)
end

-- Run a command, asserting success and returning its stdout with trailing
-- whitespace stripped. Use this for queries whose output we consume.
local function capture(args: { string }, options: RunOptions?): string
	local result = process.run(args, options)
	if not result.ok then
		error(`Command failed (exit {result.exitcode}): {table.concat(args, " ")}\n{result.stderr}`)
	end
	return (result.stdout:gsub("%s+$", ""))
end

-- Run a command for its side effects, streaming its output and asserting
-- success. Use this for mutating operations (tag, push, gh release create).
local function check(args: { string }, options: RunOptions?): ()
	local opts: RunOptions = options or {}
	if opts.stdio == nil then
		opts.stdio = "inherit"
	end
	local result = process.run(args, opts)
	if not result.ok then
		error(`Command failed (exit {result.exitcode}): {table.concat(args, " ")}`)
	end
end

return {
	run = run,
	capture = capture,
	check = check,
}
