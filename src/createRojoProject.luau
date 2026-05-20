local FlipbookBatteries = require("@pkg/flipbook-batteries@v0.9.0")
local fs = require("@std/fs")
local json = require("@std/json")
local path = require("@std/path")
local system = require("@std/system")

local config = require("@root/config")

local run = FlipbookBatteries.run

export type RojoProjectContent = {
	name: string,
	emitLegacyScripts: boolean?,
	tree: { [string]: string },
}

local function createRojoProject(projectPath: string, projectContent: RojoProjectContent): string
	local resolvedProjectPath = path.resolve(projectPath)
	fs.writeStringToFile(resolvedProjectPath, json.serialize(projectContent, true))
	return resolvedProjectPath
end

local function buildRbxm(name: string, treePath: string, outputPath: string): string
	local projectPath = path.join(system.tmpdir(), name .. ".project.json")
	local resolvedTreePath = path.resolve(treePath)

	createRojoProject(projectPath, {
		name = name,
		emitLegacyScripts = false,
		tree = { ["$path"] = tostring(resolvedTreePath) },
	})

	run(config.rojoCmd, {
		"build",
		tostring(projectPath),
		"-o",
		tostring(path.resolve(outputPath)),
	})

	fs.remove(projectPath)

	return tostring(path.resolve(outputPath))
end

return {
	createRojoProject = createRojoProject,
	buildRbxm = buildRbxm,
}
