local fs = require("@std/fs")

local constants = require("@root/constants")

local function ensureStateDir()
	fs.createDirectory(constants.STATE_DIR, { makeParents = true })
end

return ensureStateDir
