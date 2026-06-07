local exec = require("@root/release/exec")

local CONFIG = "cliff.toml"

-- Render the notes for just the latest release: `--latest` restricts git-cliff
-- to the newest tag and `--strip header` drops the changelog preamble, so the
-- output is only the current release's section. Returned as a string.
local function latestReleaseNotes(): string
	return exec.capture({ "git-cliff", "--config", CONFIG, "--latest", "--strip", "header" })
end

-- Regenerate the full CHANGELOG.md, treating unreleased commits as `tag`.
local function writeChangelog(tag: string, output: string): ()
	exec.check({ "git-cliff", "--config", CONFIG, "--tag", tag, "--output", output })
end

return {
	latestReleaseNotes = latestReleaseNotes,
	writeChangelog = writeChangelog,
}
