local runTask = require("@root/runTask")

local PRUNE_TASK_PATH = ".github/actions/deploy-storybook/tasks/prune-storybook.luau"

export type CleanupOptions = {
	prNumber: number,
	universeId: string,
	placeId: string,
	apiKey: string,
}

local function cleanup(options: CleanupOptions)
	runTask(PRUNE_TASK_PATH, {
		PR_NUMBER = options.prNumber,
	}, options.universeId, options.placeId, options.apiKey)
end

return cleanup
