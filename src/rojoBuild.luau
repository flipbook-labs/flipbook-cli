local path = require("@std/path")
local process = require("@std/process")

local config = require("./config")
local getTempDir = require("./getTempDir")

local function rojoBuild(options: {
	output: path.Pathlike,
	project: {
		name: string,
		tree: any,
	},
}): path.Path
	local projectPath = path.join(getTempDir(), `rojo-project-{options.project.name}.json`)
	local outputPath = path.resolve(options.output)

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
