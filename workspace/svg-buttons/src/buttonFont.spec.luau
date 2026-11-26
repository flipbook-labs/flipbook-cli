local fs = require("@std/fs")
local path = require("@std/path")
local test = require("@std/test")

local base64 = require("@lpm/batteries@v1.0.1-nightly.20261115/base64")

local fontData = require("@root/fontData")

-- The font sits in the `font` folder beside this spec. The path starts from
-- this file rather than the working folder, so the spec finds the font
-- whichever folder `lute test` runs from.
local SPEC_DIR = path.dirname(path.resolve(debug.info(1, "s")))
local FONT_PATH = path.join(SPEC_DIR, "font", "SchibstedGrotesk-Bold.ttf")

test.suite("button font", function(suite)
	suite:case("embeds the font file byte for byte", function(assert)
		-- Run `lute run embed-font` when this fails after replacing the font.
		local embedded = buffer.tostring(base64.decode(buffer.fromstring(fontData)))
		assert.eq(embedded == fs.readFileToString(FONT_PATH), true)
	end)
end)
