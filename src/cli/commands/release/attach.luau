local cli = require("@batteries/cli")

local exec = require("@root/release/exec")
local types = require("@root/cli/types")

local title = "release attach"
local summary = "Upload build artifacts to the draft GitHub release for a tag."

local parser = cli.parser()
parser:add("tag", "option", {
	help = "Release tag to attach files to (e.g. v1.2.3).",
	required = true,
})
parser:add("files", "variadic", {
	help = "Files to upload. Pass after `--files` or as trailing arguments.",
	required = true,
})
parser:add("help", "flag", {
	help = "Show this help message",
})

local function run()
	local tag = parser:get("tag") :: string
	local files = parser:variadics()

	-- Only ever attach to a draft. Once a release is published we don't want to
	-- mutate its assets, and a missing release shouldn't be created here.
	local draft = exec.run({ "gh", "release", "view", tag, "--json", "isDraft", "-q", ".isDraft" })
	if not draft.ok or draft.stdout:gsub("%s+$", "") ~= "true" then
		print(`No draft release for {tag}, skipping asset upload`)
		return
	end

	local args = { "gh", "release", "upload", tag }
	table.move(files, 1, #files, #args + 1, args)
	table.insert(args, "--clobber")
	exec.check(args)

	print(`Attached {#files} file(s) to {tag}`)
end

local command: types.Command = {
	run = run,
	title = title,
	summary = summary,
	parser = parser,
}

return command
