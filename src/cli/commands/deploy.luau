local cli = require("@batteries/cli")
local fs = require("@std/fs")
local process = require("@std/process")

local getFlipbookRbxmAsync = require("@root/requests/getFlipbookRbxmAsync")
local getOrCreatePlaceByNameAsync = require("@root/requests/getOrCreatePlaceByNameAsync")
local getUniverseStartPlaceAsync = require("@root/requests/getUniverseStartPlaceAsync")
local injectFlipbookAsync = require("@root/requests/injectFlipbookAsync")
local publishPlaceAsync = require("@root/requests/publishPlaceAsync")
local storybookPreviewUrl = require("@root/storybookPreviewUrl")
local types = require("@root/cli/types")

local title = "deploy"
local summary = "Deploy a place file containing your storybooks to an experience with an embedded version of Flipbook."

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
	help = "Path to an rbxl place file containing your storybooks and stories.",
	required = true,
})
parser:add("place-id", "option", {
	help = "Place ID to publish to. If omitted, the place is resolved or created by name.",
})
parser:add("flipbook-rbxm", "option", {
	help = "Path to a Flipbook rbxm to inject. By default, the latest GitHub release is downloaded.",
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

	local flipbookRbxm = parser:get("flipbook-rbxm")
	if flipbookRbxm then
		assert(
			fs.exists(flipbookRbxm) and fs.type(flipbookRbxm) == "file",
			`--flipbook-rbxm must be an existing rbxm file: {flipbookRbxm}`
		)
	end

	local startPlaceId = getUniverseStartPlaceAsync(universeId, apiKey)

	local targetPlaceId = if placeId
		then placeId
		else getOrCreatePlaceByNameAsync(universeId, placeName, {
			apiKey = apiKey,
			universeId = universeId,
			placeId = startPlaceId,
		})

	print(`Publishing place file to "{placeName}" (place {targetPlaceId})...`)
	publishPlaceAsync(universeId, targetPlaceId, placeFilePath, apiKey)

	local flipbookRbxmPath = if flipbookRbxm then flipbookRbxm else getFlipbookRbxmAsync()
	injectFlipbookAsync(flipbookRbxmPath, {
		universeId = universeId,
		placeId = targetPlaceId,
		apiKey = apiKey,
	})

	print(`Deployed storybook "{placeName}" to place {targetPlaceId}`)
	print(`View: https://roblox.com/games/{targetPlaceId}`)
	print(`Launch: {storybookPreviewUrl(targetPlaceId)}`)
end

local command: types.Command = {
	run = run,
	title = title,
	summary = summary,
	parser = parser,
}

return command
