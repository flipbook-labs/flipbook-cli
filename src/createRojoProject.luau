local fs = require("@std/fs")
local json = require("@std/json")
local path = require("@std/path")

export type RojoProjectContent = {
	name: string,
	emitLegacyScripts: boolean?,
	tree: { [string]: any },
}

local function createRojoProject(projectPath: string, projectContent: RojoProjectContent): string
	local resolvedProjectPath = tostring(path.resolve(projectPath))
	fs.writeStringToFile(resolvedProjectPath, json.serialize(projectContent, true))
	return resolvedProjectPath
end

return createRojoProject
