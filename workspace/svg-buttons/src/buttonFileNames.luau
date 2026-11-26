local types = require("@root/types")

type ButtonFileNames = types.ButtonFileNames

-- Names the files `generateButtons` writes for a button, so whatever links to
-- them can find them without drawing the button first.
local function buttonFileNames(name: string): ButtonFileNames
	return {
		light = `{name}-light.svg`,
		dark = `{name}-dark.svg`,
		fallback = `{name}-light.png`,
	}
end

return buttonFileNames
