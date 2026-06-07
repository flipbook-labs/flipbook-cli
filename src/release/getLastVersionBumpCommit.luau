local process = require("@std/process")

local config = require("@root/config")

-- The commit that last set `version = "{version}"` in loom.config.luau, or nil if
-- none matches. The gate only ever publishes the current version, whose line
-- hasn't been changed away yet, so the newest pickaxe match is the commit that
-- set it. Passed as an argv array (not a shell string) so the spaces in the
-- pickaxe expression aren't word-split.
local function getLastVersionBumpCommit(version: string): string?
	local result = process.run({
		config.gitCmd,
		"log",
		"-1",
		"--format=%H",
		"-S",
		`version = "{version}"`,
		"--",
		"loom.config.luau",
	})
	assert(result.ok, result.stderr)

	local sha = result.stdout:gsub("%s+$", "")
	if sha == "" then
		return nil
	end
	return sha
end

return getLastVersionBumpCommit
