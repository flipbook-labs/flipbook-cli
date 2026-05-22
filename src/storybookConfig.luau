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
		universeId = assert(resolvedOverrides.universeId, "--universe-id is required"),
		placeId = assert(resolvedOverrides.placeId, "--place-id is required"),
	}
end

return loadStorybookConfig
