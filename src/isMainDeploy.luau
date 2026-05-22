local constants = require("@root/constants")

local function isMainDeploy(name: string): boolean
	return name == constants.MAIN_PLACE_NAME
end

return isMainDeploy
