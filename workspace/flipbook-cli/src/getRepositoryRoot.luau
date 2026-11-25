local path = require("@std/path")
local process = require("@std/process")

-- The top of the git repository around the current folder, so paths meant to
-- be relative to the repository work from any folder inside it. Outside a
-- repository, the current folder stands in.
local function getRepositoryRoot(): path.Path
	local result = process.run({ "git", "rev-parse", "--show-toplevel" })
	if result.ok then
		return path.parse((result.stdout:gsub("%s+$", "")))
	end
	return process.cwd()
end

return getRepositoryRoot
