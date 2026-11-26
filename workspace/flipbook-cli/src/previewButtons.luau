local SvgButtons = require("@workspace/svg-buttons")

type ButtonSpec = SvgButtons.ButtonSpec

-- Where `generate` writes the buttons and `comment` links to them, relative to
-- the repository root, unless `--assets-dir` says otherwise.
local DEFAULT_ASSETS_DIR = ".github/deploy-storybook/assets"

-- The preview comment's buttons. Opening the Storybook is the main action, so
-- it gets the filled button, and the experience page on Roblox gets an
-- outlined one.
local BUTTONS: { ButtonSpec } = {
	{
		name = "join",
		label = "Open Storybook",
		leadingIcon = "play",
		colorMode = {
			light = { fill = "#8250df", border = "#6e40c9", text = "#ffffff" },
			dark = { fill = "#8957e5", border = "#a371f7", text = "#ffffff" },
		},
	},
	{
		name = "experience",
		label = "View on Roblox",
		trailingIcon = "external",
		colorMode = {
			light = { fill = "#f6f8fa", border = "#d1d9e0", text = "#25292e" },
			dark = { fill = "#212830", border = "#3d444d", text = "#f0f6fc" },
		},
	},
}

return table.freeze({
	DEFAULT_ASSETS_DIR = DEFAULT_ASSETS_DIR,
	BUTTONS = BUTTONS,
})
