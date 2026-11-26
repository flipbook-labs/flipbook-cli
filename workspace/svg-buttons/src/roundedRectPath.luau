local vector = require("@lpm/vector@v0.16.0")

type Path = vector.Path

-- How far a cubic Bézier's control points sit from its ends to approximate a
-- quarter circle.
local KAPPA = 0.5522847498

-- A rectangle with rounded corners, drawn with cubic curves so SVG and the
-- rasterizer draw the same shape. Drawing one counterclockwise inside a
-- clockwise one cuts a hole under the nonzero fill rule, which is how the
-- border is made.
local function roundedRectPath(
	x: number,
	y: number,
	width: number,
	height: number,
	radius: number,
	isCounterclockwise: boolean?
): Path
	local r = math.min(radius, width / 2, height / 2)
	local handle = r * KAPPA
	local left = x
	local right = x + width
	local top = y
	local bottom = y + height

	if isCounterclockwise then
		return {
			{ op = "M", x = right - r, y = top },
			{ op = "L", x = left + r, y = top },
			{ op = "C", x1 = left + r - handle, y1 = top, x2 = left, y2 = top + r - handle, x = left, y = top + r },
			{ op = "L", x = left, y = bottom - r },
			{
				op = "C",
				x1 = left,
				y1 = bottom - r + handle,
				x2 = left + r - handle,
				y2 = bottom,
				x = left + r,
				y = bottom,
			},
			{ op = "L", x = right - r, y = bottom },
			{
				op = "C",
				x1 = right - r + handle,
				y1 = bottom,
				x2 = right,
				y2 = bottom - r + handle,
				x = right,
				y = bottom - r,
			},
			{ op = "L", x = right, y = top + r },
			{ op = "C", x1 = right, y1 = top + r - handle, x2 = right - r + handle, y2 = top, x = right - r, y = top },
			{ op = "Z" },
		}
	end

	return {
		{ op = "M", x = left + r, y = top },
		{ op = "L", x = right - r, y = top },
		{ op = "C", x1 = right - r + handle, y1 = top, x2 = right, y2 = top + r - handle, x = right, y = top + r },
		{ op = "L", x = right, y = bottom - r },
		{
			op = "C",
			x1 = right,
			y1 = bottom - r + handle,
			x2 = right - r + handle,
			y2 = bottom,
			x = right - r,
			y = bottom,
		},
		{ op = "L", x = left + r, y = bottom },
		{
			op = "C",
			x1 = left + r - handle,
			y1 = bottom,
			x2 = left,
			y2 = bottom - r + handle,
			x = left,
			y = bottom - r,
		},
		{ op = "L", x = left, y = top + r },
		{ op = "C", x1 = left, y1 = top + r - handle, x2 = left + r - handle, y2 = top, x = left + r, y = top },
		{ op = "Z" },
	}
end

return roundedRectPath
