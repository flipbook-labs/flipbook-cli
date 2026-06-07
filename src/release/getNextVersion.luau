local parseVersion = require("@root/release/parseVersion")

export type BumpKind = "minor" | "patch"

-- Compute the next version. `minor` resets the patch (x.y.z -> x.(y+1).0);
-- `patch` increments the patch (x.y.z -> x.y.(z+1)).
local function getNextVersion(version: string, kind: BumpKind): string
	local major, minor, patch = parseVersion(version)
	if kind == "patch" then
		return `{major}.{minor}.{patch + 1}`
	end
	return `{major}.{minor + 1}.0`
end

return getNextVersion
