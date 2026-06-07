local exec = require("@root/release/exec")

-- Thin wrappers over the git queries the release commands need. Each shells out
-- to git; the gate's decision logic lives in `gate.luau` so it stays testable.

local function tagExists(tag: string): boolean
	return exec.run({ "git", "rev-parse", "-q", "--verify", `refs/tags/{tag}` }).ok
end

local function remoteTagExists(tag: string): boolean
	return exec.run({ "git", "ls-remote", "--exit-code", "origin", `refs/tags/{tag}` }).ok
end

-- How many commits sit between `tag` and HEAD.
local function commitsSince(tag: string): number
	return tonumber(exec.capture({ "git", "rev-list", "--count", `{tag}..HEAD` })) or 0
end

-- The commit that last set `version = "{version}"` in loom.config.luau. The gate
-- only ever publishes the current version, whose line hasn't been changed away
-- yet, so the newest pickaxe match is the commit that set it.
local function commitThatSetVersion(version: string): string?
	local sha = exec.capture({
		"git",
		"log",
		"-1",
		"--format=%H",
		`-Sversion = "{version}"`,
		"--",
		"loom.config.luau",
	})
	if sha == "" then
		return nil
	end
	return sha
end

return {
	tagExists = tagExists,
	remoteTagExists = remoteTagExists,
	commitsSince = commitsSince,
	commitThatSetVersion = commitThatSetVersion,
}
