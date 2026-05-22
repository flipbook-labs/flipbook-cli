local path = require("@std/path")
local process = require("@std/process")
local system = require("@std/system")

local buildPlace = require("@root/buildPlace")
local isMainDeploy = require("@root/isMainDeploy")
local loadStorybookConfig = require("@root/storybookConfig")
local publishPlace = require("@root/publishPlace")
local resolvePlaceId = require("@root/resolvePlaceId")

export type YankOptions = {
	name: string,
	universeId: string?,
	startPlaceId: string?,
}

local function yank(options: YankOptions)
	assert(not isMainDeploy(options.name), 'cannot yank the "main" place')

	local apiKey = assert(process.env.ROBLOX_API_KEY, "ROBLOX_API_KEY environment variable is required")
	local storybook = loadStorybookConfig({
		universeId = options.universeId,
		startPlaceId = options.startPlaceId,
	})
	local placeId = resolvePlaceId(options.name, storybook, apiKey)
	local rbxlPath = tostring(path.join(system.tmpdir(), `storybook-yank-{options.name}.rbxl`))

	buildPlace({
		name = `FlipbookStorybookYank-{options.name}`,
		outputRbxlPath = rbxlPath,
	})

	publishPlace(storybook.universeId, placeId, rbxlPath, apiKey)
	print(`Yanked storybook "{options.name}" (published empty place {placeId})`)
end

return yank
