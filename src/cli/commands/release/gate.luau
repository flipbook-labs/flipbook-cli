local cli = require("@batteries/cli")
local fs = require("@std/fs")
local process = require("@std/process")

local gate = require("@root/release/gate")
local git = require("@root/release/git")
local types = require("@root/cli/types")
local version = require("@root/release/version")

local title = "release gate"
local summary = "Decide whether to publish the current version or prepare the next one."

local parser = cli.parser()
parser:add("force-publish", "flag", {
	help = "Publish the current version even if it already has a tag.",
})
parser:add("help", "flag", {
	help = "Show this help message",
})

-- When run inside GitHub Actions, expose the decision as step outputs so callers
-- can gate downstream jobs on it (mirrors the old reusable workflow's outputs).
local function writeGithubOutput(result: gate.GateResult): ()
	local outputFile = process.env.GITHUB_OUTPUT
	if not outputFile then
		return
	end

	local existing = if fs.exists(outputFile) then fs.readFileToString(outputFile) else ""
	local lines = {
		`version={result.version}`,
		`should_publish={tostring(result.shouldPublish)}`,
		`has_changes={tostring(result.hasChanges)}`,
		"",
	}
	fs.writeStringToFile(outputFile, existing .. table.concat(lines, "\n"))
end

local function run()
	local current = version.read()
	local tag = `v{current}`

	local tagExists = git.tagExists(tag)
	local result = gate.evaluate({
		version = current,
		forcePublish = parser:has("force-publish"),
		tagExists = tagExists,
		commitsSinceTag = if tagExists then git.commitsSince(tag) else 0,
	})

	print(`version: {result.version}`)
	print(`should_publish: {tostring(result.shouldPublish)}`)
	print(`has_changes: {tostring(result.hasChanges)}`)

	writeGithubOutput(result)
end

local command: types.Command = {
	run = run,
	title = title,
	summary = summary,
	parser = parser,
}

return command
