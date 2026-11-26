local vector = require("@lpm/vector@v0.16.0")

local types = require("@root/types")

type IconName = types.IconName
type Path = vector.Path
type PathCommand = vector.PathCommand

-- Each icon's outline in a 12 by 12 box, drawn as shapes because the font has
-- no glyphs for them.
local ICON_POINTS: { [IconName]: { { number } } } = {
	-- A triangle pointing right.
	play = { { 2, 1, 11, 6, 2, 11 } },
	-- An arrow pointing up and to the right: its head, then its shaft.
	external = {
		{ 4, 1, 11, 1, 11, 8 },
		{ 1.16, 9.56, 7.96, 2.76, 9.24, 4.04, 2.44, 10.84 },
	},
}

local ICON_BOX = 12

-- The icon's outline scaled to `size` with its top-left corner at `x`, `y`.
local function iconPath(name: IconName, x: number, y: number, size: number): Path
	local scale = size / ICON_BOX
	local path: Path = {}
	for _, points in ICON_POINTS[name] do
		local start: PathCommand = { op = "M", x = x + points[1] * scale, y = y + points[2] * scale }
		table.insert(path, start)
		for index = 3, #points, 2 do
			local line: PathCommand = { op = "L", x = x + points[index] * scale, y = y + points[index + 1] * scale }
			table.insert(path, line)
		end
		local close: PathCommand = { op = "Z" }
		table.insert(path, close)
	end
	return path
end

return iconPath
