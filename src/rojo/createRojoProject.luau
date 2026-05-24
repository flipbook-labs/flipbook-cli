local fs = require("@std/fs")
local json = require("@std/json")
local path = require("@std/path")

local types = require("@root/rojo/types")

local function createRojoProject(projectPath: path.Pathlike, projectContent: types.RojoProjectContent): path.Path
	local resolvedProjectPath = path.resolve(projectPath)
	fs.writeStringToFile(resolvedProjectPath, json.serialize(projectContent :: json.Object, true))
	return resolvedProjectPath
end

return createRojoProject
