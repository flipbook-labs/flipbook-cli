local path = require("@std/path")
local system = require("@std/system")

local buildPlace = require("@root/buildPlace")
local isMainDeploy = require("@root/isMainDeploy")
local loadStorybookConfig = require("@root/storybookConfig")
local publishPlace = require("@root/publishPlace")
local resolvePlaceId = require("@root/resolvePlaceId")

export type YankOptions = {
	name: string,
	universeId: string?,
	placeId: string?,
	apiKey: string,
}

local function yank(options: YankOptions)
	assert(not isMainDeploy(options.name), 'cannot yank the "main" place')

	local storybook = loadStorybookConfig({
		universeId = options.universeId,
		placeId = options.placeId,
	})
	local placeId = resolvePlaceId(options.name, storybook, options.apiKey)
	local rbxlPath = tostring(path.join(system.tmpdir(), `storybook-yank-{options.name}.rbxl`))

	buildPlace({
		name = `FlipbookStorybookYank-{options.name}`,
		outputRbxlPath = rbxlPath,
	})

	publishPlace(storybook.universeId, placeId, rbxlPath, options.apiKey)
	print(`Yanked storybook "{options.name}" (published empty place {placeId})`)
end

return yank
