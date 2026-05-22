local cli = require("@batteries/cli")
local process = require("@std/process")

local helpText = require("@root/cli/helpText")
local types = require("@root/cli/types")
local yank = require("@root/yank")

local title = "yank"
local summary = "Publish an empty place to clear a PR preview."

local parser = cli.parser()

parser:add("name", "option", {
	help = "Name of the PR preview to yank.",
	required = true,
})
parser:add("api-key", "option", {
	help = "Roblox API key (Can also be supplied by the ROBLOX_API_KEY env var)",
	default = process.env.ROBLOX_API_KEY,
	required = true,
})
parser:add("universe-id", "option", {
	help = "Universe ID of the experience.",
})
parser:add("place-id", "option", {
	help = "Place ID to publish to.",
})
parser:add("help", "flag", {
	help = "Show this help message",
})

local function run(args: { string })
	parser:parse(args)

	if parser:has("help") then
		helpText.print(parser, { title = title, summary = summary })
		process.exit(0)
	end

	yank({
		name = parser:get("name") :: string,
		apiKey = parser:get("api-key") :: string,
		universeId = parser:get("universe-id"),
		placeId = parser:get("place-id"),
	})
end

local command: types.Command = {
	run = run,
	title = title,
	summary = summary,
	parser = parser,
}

return command
