local path = require("@std/path")
local process = require("@std/process")

local config = require("@root/config")
local createRojoProject = require("@root/rojo/createRojoProject")
local types = require("@root/rojo/types")

local function rojoBuild(options: {
	output: path.Pathlike,
	project: types.RojoProjectContent,
}): path.Path
	local outputPath = path.resolve(options.output)
	local projectPath = path.resolve(`{outputPath}.project.json`)

	createRojoProject(projectPath, options.project)

	local ran, result = pcall(function()
		return process.run({
			config.rojoCmd,
			"build",
			tostring(projectPath),
			"--output",
			tostring(outputPath),
		})
	end)
	if not ran then
		error(
			`Could not run "{config.rojoCmd}". Install Rojo (https://rojo.space), which deploy uses to build the place.`,
			0
		)
	end
	if not result.ok then
		error(`Rojo could not build {outputPath}:\n{result.stderr}`, 0)
	end

	return outputPath
end

return rojoBuild
