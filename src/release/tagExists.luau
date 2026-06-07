local process = require("@std/process")

local config = require("@root/config")

-- Whether a `{tag}` ref exists locally. `rev-parse --verify` exits non-zero when
-- the ref is missing, so its exit code is the answer; `-q` silences the stderr it
-- would otherwise print for a missing ref.
local function tagExists(tag: string): boolean
	return process.run({ config.gitCmd, "rev-parse", "-q", "--verify", `refs/tags/{tag}` }).ok
end

return tagExists
