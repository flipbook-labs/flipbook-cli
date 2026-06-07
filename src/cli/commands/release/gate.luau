local cli = require("@batteries/cli")
local json = require("@std/json")
local process = require("@std/process")

local config = require("@root/config")
local currentVersion = require("@root/release/currentVersion")
local evaluateGate = require("@root/release/evaluateGate")
local tagExists = require("@root/release/tagExists")
local types = require("@root/cli/types")

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
	local current = currentVersion
	local tag = `v{current}`

	-- Commits between the current version's tag and HEAD; 0 when untagged.
	local tagged = tagExists(tag)
	local commitsSinceTag = 0
	if tagged then
		local revList = process.run({ config.gitCmd, "rev-list", "--count", `{tag}..HEAD` })
		assert(revList.ok, revList.stderr)
		commitsSinceTag = tonumber(revList.stdout) or 0
	end

	local result = evaluateGate({
		version = current,
		forcePublish = parser:has("force-publish"),
		tagExists = tagged,
		commitsSinceTag = commitsSinceTag,
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
