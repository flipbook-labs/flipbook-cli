local cli = require("@batteries/cli")
local fs = require("@std/fs")
local path = require("@std/path")
local process = require("@std/process")

local getFlipbookRbxmAsync = require("@root/requests/getFlipbookRbxmAsync")
local getOrCreatePlaceByNameAsync = require("@root/requests/getOrCreatePlaceByNameAsync")
local getTempDir = require("@root/getTempDir")
local getUniverseStartPlaceAsync = require("@root/requests/getUniverseStartPlaceAsync")
local publishPlaceAsync = require("@root/requests/publishPlaceAsync")
local rojoBuild = require("@root/rojo/rojoBuild")
local storybookPreviewUrl = require("@root/storybookPreviewUrl")
local types = require("@root/cli/types")

local title = "deploy"
local summary = "Deploy an rbxm file containing your storybooks and stories to an experience for previewing."

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
parser:add("stories", "option", {
	help = "Path to an rbxm file containing storybooks and stories.",
	required = true,
})
parser:add("place-id", "option", {
	help = "Place ID to publish to. If omitted, the place is resolved or created by name.",
})
parser:add("flipbook-rbxm", "option", {
	help = "Optional path to the Flipbook plugin to use as the runtime. When omitted, the latest version from GitHub is used.",
})
parser:add("dry-run", "option", {
	help = "Skip any steps that would make changes to the live Roblox experience.",
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

	local storiesPath = parser:get("stories") :: string
	assert(
		fs.exists(storiesPath) and fs.type(storiesPath) == "file",
		`--stories needs to be an rbxm file: {storiesPath}`
	)

	local dryRun = parser:get("dry-run")
	local placeId = tonumber(parser:get("place-id"))

	local flipbookRbxmPath = if parser:get("flipbook-rbxm") then parser:get("flipbook-rbxm") else getFlipbookRbxmAsync()

	print("Building rbxl for deployment...")
	local outputRbxlPath = rojoBuild({
		output = path.join(getTempDir(), `deploy-{os.time()}.rbxl`),
		project = {
			name = placeName,
			emitLegacyScripts = false,
			tree = {
				["$className"] = "DataModel",
				ReplicatedStorage = {
					Flipbook = {
						["$path"] = flipbookRbxmPath,
					},
					Stories = {
						["$path"] = storiesPath,
					},
				},
			},
		},
	})

	local startPlaceId = getUniverseStartPlaceAsync(universeId, apiKey)

	local allocatedPlaceId = if placeId
		then placeId
		else getOrCreatePlaceByNameAsync(universeId, placeName, {
			apiKey = apiKey,
			universeId = universeId,
			placeId = startPlaceId,
		})

	if dryRun then
		return
	end

	publishPlaceAsync(universeId, allocatedPlaceId, outputRbxlPath, apiKey)

	print(`Published storybook "{placeName}" to place {allocatedPlaceId})`)
	print("Play: " .. storybookPreviewUrl(startPlaceId, allocatedPlaceId))
end

local command: types.Command = {
	run = run,
	title = title,
	summary = summary,
	parser = parser,
}

return command
