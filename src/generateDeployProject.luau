local fs = require("@std/fs")
local path = require("@std/path")

local constants = require("@root/constants")
local createRojoProject = require("@root/createRojoProject")
local ensureStateDir = require("@root/ensureStateDir")

type RojoProjectContent = createRojoProject.RojoProjectContent

export type DeployProjectOptions = {
	name: string,
	flipbookRbxmPath: string?,
	storiesPath: string?,
	outputProjectPath: string?,
	outputRbxlPath: string?,
}

local function deployProjectPath(name: string): string
	return tostring(path.join(constants.STATE_DIR, `deploy-{name}.project.json`))
end

local function generateDeployProject(options: DeployProjectOptions): string
	local replicatedStorage: { [string]: any } = {}

	if options.flipbookRbxmPath then
		local flipbookRbxmPath = tostring(path.resolve(options.flipbookRbxmPath))
		assert(fs.exists(flipbookRbxmPath), `Flipbook.rbxm not found: {flipbookRbxmPath}`)
		assert(fs.type(flipbookRbxmPath) == "file", `Flipbook path is not a file: {flipbookRbxmPath}`)
		replicatedStorage.Flipbook = { ["$path"] = flipbookRbxmPath }
	end

	if options.storiesPath then
		local storiesPath = tostring(path.resolve(options.storiesPath))
		assert(fs.exists(storiesPath), `stories path not found: {storiesPath}`)
		replicatedStorage.Stories = { ["$path"] = storiesPath }
	end

	local tree: { [string]: any } = {
		["$className"] = "DataModel",
	}
	if next(replicatedStorage) ~= nil then
		tree.ReplicatedStorage = replicatedStorage
	end

	local projectContent: RojoProjectContent = {
		name = options.name,
		emitLegacyScripts = false,
		tree = tree,
	}

	ensureStateDir()
	local projectPath = options.outputProjectPath or deployProjectPath(options.name)
	return createRojoProject(projectPath, projectContent)
end

return generateDeployProject
