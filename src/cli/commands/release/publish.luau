local FlipbookBatteries = require("@pkg/flipbook-batteries@v0.9.0")
local cli = require("@batteries/cli")
local fs = require("@std/fs")
local path = require("@std/path")
local process = require("@std/process")

local config = require("@root/config")
local getCurrentVersion = require("@root/release/getCurrentVersion")
local getLastVersionBumpCommit = require("@root/release/getLastVersionBumpCommit")
local getTempDir = require("@root/getTempDir")
local types = require("@root/cli/types")

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
	local current = parser:get("version") or getCurrentVersion()
	local tag = `v{current}`

	-- Tag the commit that set this version rather than whichever commit happened
	-- to trip the gate.
	local sha = assert(
		getLastVersionBumpCommit(current),
		`Could not find the commit that set version {current} in loom.config.luau`
	)

	-- A non-zero exit from `ls-remote --exit-code` means the tag isn't on origin.
	local remoteTag = process.run({ config.gitCmd, "ls-remote", "--exit-code", "origin", `refs/tags/{tag}` })
	if remoteTag.ok then
		print(`Tag {tag} already exists on origin`)
	else
		FlipbookBatteries.run(config.gitCmd, { "tag", tag, sha })
		FlipbookBatteries.run(config.gitCmd, { "push", "origin", tag })
		print(`Pushed tag {tag}`)
	end

	if process.run({ config.ghCmd, "release", "view", tag }).ok then
		print(`Draft release {tag} already exists`)
		return
	end

	-- Render notes for just this release: `--latest` restricts git-cliff to the
	-- newest tag and `--strip header` drops the changelog preamble.
	local notes = process.run({ config.gitCliffCmd, "--config", "cliff.toml", "--latest", "--strip", "header" })
	assert(notes.ok, notes.stderr)

	local notesPath = tostring(path.join(getTempDir(), "release-notes.md"))
	fs.writeStringToFile(notesPath, (notes.stdout:gsub("%s+$", "")))

	FlipbookBatteries.run(config.ghCmd, {
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
