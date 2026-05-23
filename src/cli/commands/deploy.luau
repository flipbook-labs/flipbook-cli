local cli = require("@batteries/cli")
local fs = require("@std/fs")
local path = require("@std/path")
local process = require("@std/process")

local getFlipbookRbxmAsync = require("@root/requests/getFlipbookRbxmAsync")
local getTempDir = require("@root/getTempDir")
local publishPlaceAsync = require("@root/requests/publishPlaceAsync")
local resolvePlaceIdAsync = require("@root/requests/resolvePlaceIdAsync")
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
parser:add("dry-run", "option", {
	help = "Skip any steps that would make changes to the live Roblox experience.",
})
parser:add("help", "flag", {
	help = "Show this help message",
})

export type DeployOptions = {
	placeName: string,
	apiKey: string,
	storiesPath: path.Pathlike,
	universeId: string,

	placeId: string?,
	dryRun: string?,
}

local function run(args: { string })
	parser:parse(args)

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

	local flipbookRbxmPath = getFlipbookRbxmAsync()

	local outputRbxlPath = rojoBuild({
		output = path.join(getTempDir(), `deploy-{placeName}.rbxl`),
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

	if dryRun then
		return
	end

	local allocatedPlaceId, created = resolvePlaceIdAsync(placeName, {
		apiKey = apiKey,
		universeId = universeId,
		placeId = placeId,
	})
	publishPlaceAsync(universeId, allocatedPlaceId, outputRbxlPath, apiKey)

	print(`Published storybook "{placeName}" to place {allocatedPlaceId} (created={created})`)
	print("Play: " .. storybookPreviewUrl(allocatedPlaceId))
end

local command: types.Command = {
	run = run,
	title = title,
	summary = summary,
	parser = parser,
}

return command
