local path = require("@std/path")
local system = require("@std/system")

local buildPlace = require("@root/buildPlace")
local fetchFlipbookRbxm = require("@root/fetchFlipbookRbxm")
local loadStorybookConfig = require("@root/storybookConfig")
local publishPlace = require("@root/publishPlace")
local resolvePlaceId = require("@root/resolvePlaceId")
local storybookPreviewUrl = require("@root/storybookPreviewUrl")

export type DeployOptions = {
	name: string,
	apiKey: string,
	storiesPath: string,
	universeId: string,

	placeId: string?,
	dryRun: string?,
}

local function deploy(options: DeployOptions)
	local flipbookRbxmPath = fetchFlipbookRbxm()
	local rbxlPath = options.dryRun or tostring(path.join(system.tmpdir(), `storybook-{options.name}.rbxl`))

	buildPlace({
		name = `FlipbookStorybook-{options.name}`,
		flipbookRbxmPath = flipbookRbxmPath,
		storiesPath = options.storiesPath,
		outputRbxlPath = rbxlPath,
	})

	if options.dryRun then
		print(`Built {rbxlPath}`)
		return
	end

	local storybook = loadStorybookConfig({
		universeId = options.universeId,
		placeId = options.placeId,
	})
	local placeId, created = resolvePlaceId(options.name, storybook, options.apiKey)
	publishPlace(storybook.universeId, placeId, rbxlPath, options.apiKey)

	print(`Published storybook "{options.name}" to place {placeId} (created={created})`)
	print("Play: " .. storybookPreviewUrl(placeId))
end

return deploy
