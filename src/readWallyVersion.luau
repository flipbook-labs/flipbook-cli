local fs = require("@std/fs")
local toml = require("@batteries/toml")

local function readWallyVersion(): string
	local manifest = toml.deserialize(fs.readFileToString("wally.toml")) :: any
	return tostring(manifest.package.version)
end

return readWallyVersion
