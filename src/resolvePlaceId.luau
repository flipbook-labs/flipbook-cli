local isMainDeploy = require("@root/isMainDeploy")
local runTask = require("@root/runTask")
local storybookConfig = require("@root/storybookConfig")
local resolveOrCreatePlaceScript = require("@root/tasks/resolve-or-create-place")

local function resolvePlaceId(
	name: string,
	storybook: storybookConfig.StorybookConfig,
	apiKey: string
): (string, boolean)
	if isMainDeploy(name) then
		return storybook.startPlaceId, false
	end

	local result = runTask(
		resolveOrCreatePlaceScript,
		{
			DESIRED_NAME = name,
			TEMPLATE_PLACE_ID = storybook.startPlaceId,
		},
		storybook.universeId,
		storybook.startPlaceId,
		apiKey
	) :: { placeId: number, created: boolean? }

	assert(result and result.placeId, "failed to resolve or create place")
	return tostring(result.placeId), result.created == true
end

return resolvePlaceId
