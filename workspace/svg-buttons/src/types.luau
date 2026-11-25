local vector = require("@lpm/vector@v0.16.0")

export type Path = vector.Path

-- Hex colors for one button in one color mode. The label and icons share the
-- text color.
export type ButtonPalette = {
	fill: string,
	border: string,
	text: string,
}

-- What a button is drawn with in each color mode, so GitHub can show the one
-- that matches the viewer's.
export type ByColorMode<T> = {
	light: T,
	dark: T,
}

export type IconName = "play" | "external"

export type ButtonSpec = {
	-- The file name stem, such as `join` for `join-light.svg`.
	name: string,
	label: string,
	leadingIcon: IconName?,
	trailingIcon: IconName?,
	colorMode: ByColorMode<ButtonPalette>,
}

export type ButtonMetrics = {
	read height: number,
	read cornerRadius: number,
	read borderWidth: number,
	read paddingX: number,
	read fontSize: number,
	read letterSpacing: number,
	read iconSize: number,
	read iconGap: number,
}

-- The shapes that make up one button, painted in order.
export type ButtonLayers = {
	width: number,
	height: number,
	border: Path,
	fill: Path,
	icons: Path,
	text: Path,
}

export type ButtonFile = {
	name: string,
	contents: string,
}

return nil
