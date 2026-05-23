local fs = require("@std/fs")
local path = require("@std/path")
local system = require("@std/system")

local function getTempDir(): string
	local dir = tostring(path.join(system.tmpdir(), "flipbook-cli"))
	fs.createDirectory(dir, { makeParents = true })
	return dir
end

return getTempDir
