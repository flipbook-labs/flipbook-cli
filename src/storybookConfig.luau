local process = require("@std/process")

export type StorybookConfig = {
	universeId: string,
	placeId: string,
}

export type StorybookConfigOverrides = {
	universeId: string?,
	placeId: string?,
}

local function loadStorybookConfig(overrides: StorybookConfigOverrides?): StorybookConfig
	local resolvedOverrides = if overrides then overrides else {} :: StorybookConfigOverrides

	return {
		universeId = resolvedOverrides.universeId or assert(
			process.env.ROBLOX_STORYBOOK_UNIVERSE_ID,
			"ROBLOX_STORYBOOK_UNIVERSE_ID is required (or pass --universe-id)"
		),
		placeId = resolvedOverrides.placeId or assert(
			process.env.ROBLOX_STORYBOOK_PLACE_ID,
			"ROBLOX_STORYBOOK_PLACE_ID is required (or pass --place-id)"
		),
	}
end

return loadStorybookConfig
