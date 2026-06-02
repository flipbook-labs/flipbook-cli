local injectFlipbookTask = require("@root/tasks/injectFlipbook")
local runTaskAsync = require("@root/requests/runTaskAsync")
local types = require("@root/types")

type LuauExecutionContext = types.LuauExecutionContext

local function injectFlipbookAsync(assetId: number, luauExecutionContext: LuauExecutionContext)
	print(`Injecting Flipbook asset {assetId} into place {luauExecutionContext.placeId}...`)

	runTaskAsync(injectFlipbookTask, {
		ASSET_ID = assetId,
	}, luauExecutionContext)

	print("Flipbook injected and place saved.")
end

return injectFlipbookAsync
