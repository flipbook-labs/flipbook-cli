-- Draws buttons as image files for places that can't style links, like
-- GitHub comments: a light and a dark SVG for each button, plus a PNG fallback.
local generateButtons = require("@self/generateButtons")
local types = require("@self/types")

export type ButtonFile = types.ButtonFile
export type ButtonPalette = types.ButtonPalette
export type ButtonSpec = types.ButtonSpec
export type ByColorMode<T> = types.ByColorMode<T>
export type IconName = types.IconName

return {
	generateButtons = generateButtons,
}
