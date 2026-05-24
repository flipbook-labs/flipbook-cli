local cli = require("@batteries/cli")
local path = require("@std/path")
local process = require("@std/process")

local types = require("@root/cli/types")

local getOrCreatePlaceByNameAsync = require("@root/requests/getOrCreatePlaceByNameAsync")
local getTempDir = require("@root/getTempDir")
local publishPlaceAsync = require("@root/requests/publishPlaceAsync")
local rojoBuild = require("@root/rojo/rojoBuild")

export type YankOptions = {
	placeName: string,
	apiKey: string,
	universeId: number,
	placeId: number?,
}

local title = "yank"
local summary = "Publish an empty place to clear a PR preview."

local parser = cli.parser()

parser:add("place-name", "option", {
	help = "Name of place to yank.",
	required = true,
	aliases = { "n" },
})
parser:add("api-key", "option", {
	help = "Roblox API key (Can also be supplied by the ROBLOX_API_KEY env var)",
	aliases = { "k" },
})
parser:add("universe-id", "option", {
	help = "Universe ID of the experience.",
	required = true,
	aliases = { "u" },
})
parser:add("place-id", "option", {
	help = "Place ID to publish to.",
	aliases = { "p" },
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
	local placeId =
		assert(tonumber(parser:get("place-id")), `--place-id must be a number, got "{parser:get("place-id")}"`)

	local allocatedPlaceId = getOrCreatePlaceByNameAsync(universeId, placeName, {
		apiKey = apiKey,
		universeId = universeId,
		placeId = placeId,
	})

	local emptyPlacePath = rojoBuild({
		output = path.join(getTempDir(), "Empty.rbxl"),
		project = {
			name = "Empty",
			tree = {
				["$className"] = "DataModel",
			},
		},
	})

	publishPlaceAsync(universeId, allocatedPlaceId, emptyPlacePath, apiKey)
	print(`Yanked storybook "{placeName}" (published empty place {allocatedPlaceId})`)
end

local command: types.Command = {
	run = run,
	title = title,
	summary = summary,
	parser = parser,
}

return command
