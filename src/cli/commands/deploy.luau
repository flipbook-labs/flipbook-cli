local cli = require("@batteries/cli")
local process = require("@std/process")

local deploy = require("@root/deploy")

local function help()
	print([[
flipbook-cli deploy
Build and publish a storybook place (Open Cloud).

USAGE:
  flipbook-cli deploy [options]

OPTIONS:
  --name <name>              Place name (default: main). Use pr-<number> for PR previews.
  --stories <path>           Optional .rbxm (or directory) mounted as ReplicatedStorage.Stories
  --universe-id <id>         Experience (universe) ID. Overrides ROBLOX_STORYBOOK_UNIVERSE_ID.
  --place-id <id>            Root place ID. Overrides ROBLOX_STORYBOOK_PLACE_ID / ROBLOX_STORYBOOK_PLACE_ID.
  --flipbook-rbxm <path>     Prebuilt Flipbook.rbxm (skips GitHub download)
  --dry-run <path>           Build .rbxl locally only (skip Open Cloud publish)
  --help                     Show this help message

ENV VARS (required for publish):
  ROBLOX_API_KEY                  Roblox API key
  ROBLOX_STORYBOOK_UNIVERSE_ID    Experience (universe) ID
  ROBLOX_STORYBOOK_PLACE_ID Root place ID (main deploy target; template for new PR places)

ENV VARS (Flipbook.rbxm):
  FLIPBOOK_GITHUB_REPO            GitHub repo (default: flipbook-labs/flipbook)
  FLIPBOOK_RELEASE_TAG            Pin a release tag (default: latest)
  FLIPBOOK_RBXM_ASSET             Release asset name (default: Flipbook.rbxm)
  FLIPBOOK_RBXM_PATH              Local Flipbook.rbxm (skips download)
  GITHUB_TOKEN                    Optional; avoids GitHub API rate limits in CI

NOTES:
  --name main publishes to the experience start place.
  Other names resolve or create a place (cloned from the start place) via Luau Execution on the start place.
  By default, Flipbook.rbxm is downloaded from the latest GitHub release and cached under system.tmpdir().
]])
end

local function run(args: { string })
	local parser = cli.parser()

	parser:add("name", "option", { help = "Place name", default = "main" })
	parser:add("stories", "option", { help = "Stories .rbxm or directory" })
	parser:add("universe-id", "option", { help = "Experience (universe) ID" })
	parser:add("place-id", "option", { help = "Root place ID" })
	parser:add("flipbook-rbxm", "option", { help = "Path to Flipbook.rbxm" })
	parser:add("dry-run", "option", { help = "Output .rbxl path without publishing" })
	parser:add("help", "flag")

	parser:parse(args)

	if parser:has("help") then
		help()
		process.exit(0)
	end

	deploy({
		name = parser:get("name") or "main",
		storiesPath = parser:get("stories"),
		universeId = parser:get("universe-id"),
		startPlaceId = parser:get("place-id"),
		flipbookRbxmPath = parser:get("flipbook-rbxm"),
		dryRun = parser:get("dry-run"),
	})
end

return { run = run }
