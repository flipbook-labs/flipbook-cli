local base64 = require("@lpm/batteries@v1.0.1-nightly.20261115/base64")
local truetype = require("@lpm/truetype@v0.16.0")

local fontData = require("@root/fontData")

type Font = truetype.Font

local font: Font? = nil

-- Decoded on first use, since only generating buttons needs it.
local function getButtonFont(): Font
	if font == nil then
		font = truetype.readTrueTypeFont(base64.decode(buffer.fromstring(fontData)))
	end
	return font :: Font
end

return getButtonFont
