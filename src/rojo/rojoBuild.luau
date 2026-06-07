local FlipbookBatteries = require("@pkg/flipbook-batteries@v0.10.1")
local path = require("@std/path")

local config = require("@root/config")
local createRojoProject = require("@root/rojo/createRojoProject")
local getTempDir = require("@root/getTempDir")
local types = require("@root/rojo/types")

local run = FlipbookBatteries.run

local function rojoBuild(options: {
	output: path.Pathlike,
	project: types.RojoProjectContent,
}): path.Path
	local projectPath = path.join(getTempDir(), `{os.time()}.project.json`)
	local outputPath = path.resolve(options.output)

	createRojoProject(projectPath, options.project)

	run(config.rojoCmd, {
		"build",
		projectPath,
		"--output",
		outputPath,
	})

	return outputPath
end

return rojoBuild
