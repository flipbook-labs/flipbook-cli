local path = require("@std/path")
local system = require("@std/system")

local tmp = system.tmpdir()

local STATE_DIR = tostring(path.join(tmp, "flipbook-cli"))

return {
	STATE_DIR = STATE_DIR,
	FLIPBOOK_RBXM_CACHE = tostring(path.join(STATE_DIR, "Flipbook.rbxm")),
	FLIPBOOK_RELEASE_META = tostring(path.join(STATE_DIR, "flipbook-release.json")),
}
