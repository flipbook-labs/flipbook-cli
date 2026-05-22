local FlipbookBatteries = require("@pkg/flipbook-batteries@v0.9.0")
local fs = require("@std/fs")
local path = require("@std/path")

local config = require("@root/config")
local generateDeployProject = require("@root/generateDeployProject")

local run = FlipbookBatteries.run

type DeployProjectOptions = generateDeployProject.DeployProjectOptions

local function buildPlace(options: DeployProjectOptions): string
	assert(options.outputRbxlPath, "outputRbxlPath is required")
	local projectPath = generateDeployProject(options)
	local outputRbxlPath = tostring(path.resolve(options.outputRbxlPath))
	run(config.rojoCmd, {
		"build",
		projectPath,
		"-o",
		outputRbxlPath,
	})
	if not options.outputProjectPath then
		fs.remove(projectPath)
	end
	return outputRbxlPath
end

return buildPlace
