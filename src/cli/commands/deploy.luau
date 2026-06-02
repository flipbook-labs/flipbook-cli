local cli = require("@batteries/cli")
local fs = require("@std/fs")
local process = require("@std/process")

local getFlipbookAssetIdAsync = require("@root/requests/getFlipbookAssetIdAsync")
local getOrCreatePlaceByNameAsync = require("@root/requests/getOrCreatePlaceByNameAsync")
local getUniverseStartPlaceAsync = require("@root/requests/getUniverseStartPlaceAsync")
local injectFlipbookAsync = require("@root/requests/injectFlipbookAsync")
local publishPlaceAsync = require("@root/requests/publishPlaceAsync")
local storybookPreviewUrl = require("@root/storybookPreviewUrl")
local types = require("@root/cli/types")

local title = "deploy"
local summary = "Deploy a place file containing your storybooks to an experience, injecting the Flipbook runtime after publish."

local parser = cli.parser()

parser:add("place-name", "option", {
	help = "Name of the place to update or create for this deployment.",
	required = true,
})
parser:add("api-key", "option", {
	help = "Roblox API key (Can also be supplied by the ROBLOX_API_KEY env var)",
})
parser:add("universe-id", "option", {
	help = "Universe to deploy to.",
	required = true,
})
parser:add("place-file", "option", {
	help = "Path to an rbxl place file to deploy. Must already contain stories and their dependencies in their authored layout.",
	required = true,
})
parser:add("place-id", "option", {
	help = "Place ID to publish to. If omitted, the place is resolved or created by name.",
})
parser:add("flipbook-asset", "option", {
	help = "Roblox asset ID of the Flipbook runtime to inject. When omitted, the ID is fetched from the latest GitHub release.",
})
parser:add("dry-run", "flag", {
	help = "Publish the place but skip the Flipbook injection step.",
})
parser:add("help", "flag", {
	help = "Show this help message",
})

local function run()
	local apiKey = assert(
		parser:get("api-key") or process.env.ROBLOX_API_KEY,
		"An Open Cloud API key is required, use --api-key or the ROBLOX_API_KEY env var to supply it"
	)

	local placeName = parser:get("place-name") :: string

	local universeIdStr = parser:get("universe-id")
	local universeId = assert(tonumber(universeIdStr), `--universe-id must be a number, got "{universeIdStr}"`)

	local placeFilePath = parser:get("place-file") :: string
	assert(
		fs.exists(placeFilePath) and fs.type(placeFilePath) == "file",
		`--place-file must be an existing rbxl file: {placeFilePath}`
	)

	local placeId = tonumber(parser:get("place-id"))
	local dryRun = parser:has("dry-run")

	local flipbookAssetIdStr = parser:get("flipbook-asset")
	local flipbookAssetId: number = if flipbookAssetIdStr
		then assert(tonumber(flipbookAssetIdStr), `--flipbook-asset must be a number, got "{flipbookAssetIdStr}"`)
		else getFlipbookAssetIdAsync()

	local startPlaceId = getUniverseStartPlaceAsync(universeId, apiKey)

	local allocatedPlaceId = if placeId
		then placeId
		else getOrCreatePlaceByNameAsync(universeId, placeName, {
			apiKey = apiKey,
			universeId = universeId,
			placeId = startPlaceId,
		})

	print(`Publishing place file to "{placeName}" (place {allocatedPlaceId})...`)
	publishPlaceAsync(universeId, allocatedPlaceId, placeFilePath, apiKey)
	print("Place published.")

	if not dryRun then
		injectFlipbookAsync(flipbookAssetId, {
			universeId = universeId,
			placeId = allocatedPlaceId,
			apiKey = apiKey,
		})
	end

	print(`Deployed storybook "{placeName}" to place {allocatedPlaceId}`)
	print("Play: " .. storybookPreviewUrl(startPlaceId, allocatedPlaceId))
end

local command: types.Command = {
	run = run,
	title = title,
	summary = summary,
	parser = parser,
}

return command
