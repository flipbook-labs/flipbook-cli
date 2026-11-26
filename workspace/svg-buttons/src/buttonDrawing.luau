local types = require("@root/types")

type ButtonMetrics = types.ButtonMetrics

-- How every button is drawn. The sizes follow GitHub's medium buttons, so the
-- buttons sit naturally in a comment.
return table.freeze({
	-- The PNG fallback is drawn at this multiple of the button's size, so it
	-- stays sharp on high-density screens.
	pngScale = 2,
	metrics = table.freeze<<ButtonMetrics>>({
		height = 32,
		cornerRadius = 6,
		borderWidth = 1,
		paddingX = 14,
		fontSize = 14,
		letterSpacing = 0,
		iconSize = 12,
		iconGap = 6,
	}),
})
