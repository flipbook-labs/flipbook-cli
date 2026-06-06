local injectFlipbookTask = require("@root/tasks/injectFlipbook")
local runTaskAsync = require("@root/requests/runTaskAsync")
local types = require("@root/types")

type LuauExecutionContext = types.LuauExecutionContext

local function injectFlipbookAsync(rbxmPath: string, luauExecutionContext: LuauExecutionContext)
	print(`Injecting Flipbook into place {luauExecutionContext.placeId}...`)

	runTaskAsync(injectFlipbookTask, {}, luauExecutionContext, rbxmPath)

	print("Flipbook injected and place saved.")
end

return injectFlipbookAsync
