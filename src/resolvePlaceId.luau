local isMainDeploy = require("@root/isMainDeploy")
local resolveOrCreatePlaceScript = require("@root/tasks/resolve-or-create-place")
local runTask = require("@root/runTask")
local storybookConfig = require("@root/storybookConfig")

local function resolvePlaceId(
	name: string,
	storybook: storybookConfig.StorybookConfig,
	apiKey: string
): (string, boolean)
	if isMainDeploy(name) then
		return storybook.placeId, false
	end

	local result: { placeId: number, created: boolean? } = runTask(resolveOrCreatePlaceScript, {
		DESIRED_NAME = name,
		TEMPLATE_PLACE_ID = storybook.placeId,
	}, storybook.universeId, storybook.placeId, apiKey)

	assert(result and result.placeId, "failed to resolve or create place")
	return tostring(result.placeId), result.created == true
end

return resolvePlaceId
