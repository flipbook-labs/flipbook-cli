local path = require("@std/path")
local process = require("@std/process")

local config = require("@root/config")
local createRojoProject = require("@root/rojo/createRojoProject")
local getTempDir = require("@root/getTempDir")
local types = require("@root/rojo/types")

local function rojoBuild(options: {
	output: path.Pathlike,
	project: types.RojoProjectContent,
}): path.Path
	local projectPath = path.join(getTempDir(), `rojo-project-{options.project.name}.json`)
	local outputPath = path.resolve(options.output)

	createRojoProject(projectPath, options.project)

	process.run({
		config.rojoCmd,
		"build",
		tostring(projectPath),
		"--output",
		tostring(outputPath),
	})

	return outputPath
end

return rojoBuild
