local cli = require("@batteries/cli")
local json = require("@std/json")

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

local function run()
	local current = version.current
	local tag = `v{current}`

	local tagExists = git.tagExists(tag)
	local result = gate.evaluate({
		version = current,
		forcePublish = parser:has("force-publish"),
		tagExists = tagExists,
		commitsSinceTag = if tagExists then git.commitsSince(tag) else 0,
	})

	-- Emit the decision as JSON on stdout so callers (the release workflow, or a
	-- person) can parse it. Deliberately environment-agnostic: the workflow is
	-- responsible for any GitHub Actions plumbing (e.g. piping into
	-- $GITHUB_OUTPUT), not the CLI.
	print(json.serialize({
		version = result.version,
		should_publish = result.shouldPublish,
		has_changes = result.hasChanges,
	}))
end

local command: types.Command = {
	run = run,
	title = title,
	summary = summary,
	parser = parser,
}

return command
