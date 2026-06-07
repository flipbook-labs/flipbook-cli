local cli = require("@batteries/cli")
local fs = require("@std/fs")
local path = require("@std/path")

local cliff = require("@root/release/cliff")
local exec = require("@root/release/exec")
local getTempDir = require("@root/getTempDir")
local git = require("@root/release/git")
local types = require("@root/cli/types")
local version = require("@root/release/version")

local title = "release publish"
local summary = "Tag the current version and open a draft GitHub release with generated notes."

local parser = cli.parser()
parser:add("version", "option", {
	help = "Version to publish. Defaults to the version in loom.config.luau.",
})
parser:add("help", "flag", {
	help = "Show this help message",
})

local function run()
	local current = parser:get("version") or version.read()
	local tag = `v{current}`

	-- Tag the commit that set this version rather than whichever commit happened
	-- to trip the gate.
	local sha = assert(
		git.commitThatSetVersion(current),
		`Could not find the commit that set version {current} in loom.config.luau`
	)

	if git.remoteTagExists(tag) then
		print(`Tag {tag} already exists on origin`)
	else
		exec.check({ "git", "tag", tag, sha })
		exec.check({ "git", "push", "origin", tag })
		print(`Pushed tag {tag}`)
	end

	if exec.run({ "gh", "release", "view", tag }).ok then
		print(`Draft release {tag} already exists`)
		return
	end

	local notesPath = tostring(path.join(getTempDir(), "release-notes.md"))
	fs.writeStringToFile(notesPath, cliff.latestReleaseNotes())

	exec.check({
		"gh",
		"release",
		"create",
		tag,
		"--draft",
		"--title",
		tag,
		"--target",
		sha,
		"--notes-file",
		notesPath,
	})
	print(`Created draft release {tag}`)
end

local command: types.Command = {
	run = run,
	title = title,
	summary = summary,
	parser = parser,
}

return command
