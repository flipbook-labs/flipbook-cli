local FlipbookBatteries = require("@pkg/flipbook-batteries@v0.9.0")
local cli = require("@batteries/cli")
local process = require("@std/process")

local config = require("@root/config")
local getCurrentVersion = require("@root/release/getCurrentVersion")
local getNextVersion = require("@root/release/getNextVersion")
local types = require("@root/cli/types")
local writeVersion = require("@root/release/writeVersion")

local run = FlipbookBatteries.run

type VersionComponent = getNextVersion.VersionComponent

local title = "release prepare-pr"
local summary = "Bump the version, regenerate the changelog, and open/update the publish PR."

-- A stable identity for the publish commit so it isn't attributed to whoever's
-- credentials happen to be configured in the runner.
local GIT_AUTHOR_NAME = "github-actions[bot]"
local GIT_AUTHOR_EMAIL = "41898282+github-actions[bot]@users.noreply.github.com"

local parser = cli.parser()
parser:add("bump", "option", {
	help = "Which semver component to bump when preparing the next release (major | minor | patch).",
	default = "minor",
})
parser:add("base", "option", {
	help = "Base branch the publish PR targets.",
	default = "main",
})
parser:add("branch", "option", {
	help = "Head branch for the publish PR.",
	default = "publish-next-version",
})
parser:add("template", "option", {
	help = "Markdown body for the publish PR. `{{version}}` is replaced with the next version "
		.. "and `{{releaseUrl}}` with the URL of its release. Falls back to a built-in body.",
})
parser:add("help", "flag", {
	help = "Show this help message",
})

-- The publish PR body, used when `--template` isn't supplied. The workflow that
-- drives this command passes its own template so it can fold in run-specific
-- context (e.g. a link back to the Actions run) that the CLI has no way to know.
local DEFAULT_PR_TEMPLATE = table.concat({
	">[!IMPORTANT]",
	"> This PR prepares the next release by bumping the version and updating the changelog.",
	">",
	"> **Merging this PR will:**",
	">",
	"> 1. Create and push tag `v{{version}}`",
	"> 2. Create a draft GitHub release for that tag",
	"> 3. Trigger binary builds for macOS, Linux, and Windows",
	"> 4. Attach release assets to the draft release",
	"",
	"Next release will be available here: ",
	"{{releaseUrl}}",
}, "\n")

local function getRepoSlug(): string
	if process.env.GITHUB_REPOSITORY then
		return process.env.GITHUB_REPOSITORY
	end
	-- GITHUB_REPOSITORY is set in Actions; fall back to gh for local runs.
	local result = process.run({
		config.ghCmd,
		"repo",
		"view",
		"--json",
		"nameWithOwner",
		"-q",
		".nameWithOwner",
	})
	assert(result.ok, result.stderr)
	local slug = result.stdout:gsub("%s+$", "")
	return slug
end

local function preparePr()
	local current = getCurrentVersion()

	local bumpOption = parser:get("bump")
	local bumpKind: VersionComponent
	if bumpOption == "major" then
		bumpKind = "major"
	elseif bumpOption == "patch" then
		bumpKind = "patch"
	elseif bumpOption == "minor" then
		bumpKind = "minor"
	else
		error(`Unknown version component "{bumpOption}"`)
	end

	-- `rev-parse --verify` exits non-zero when the ref is missing, so its exit
	-- code answers whether the tag exists; `-q` silences the stderr it would print.
	local tagExists = process.run({ config.gitCmd, "rev-parse", "-q", "--verify", `refs/tags/v{current}` }).ok

	-- If the current version is already tagged, bump to the next one; otherwise
	-- the version hasn't been released yet, so prepare a PR for it as-is.
	local nextVersion = if tagExists then getNextVersion(current, bumpKind) else current
	local nextTag = `v{nextVersion}`

	writeVersion(nextVersion)
	-- Regenerate the full changelog, treating unreleased commits as `nextTag`.
	run(config.gitCliffCmd, {
		"--config",
		"cliff.toml",
		"--tag",
		nextTag,
		"--output",
		"CHANGELOG.md",
	})

	local base = parser:get("base") :: string
	local branch = parser:get("branch") :: string

	run(config.gitCmd, { "switch", "-C", branch })
	run(config.gitCmd, { "add", "CHANGELOG.md", "loom.config.luau" })

	-- `diff --cached --quiet` exits 0 when the index is clean. On re-runs where
	-- the version and changelog are already at the target state nothing will be
	-- staged, so skip the commit rather than letting git fail with "nothing to
	-- commit".
	local hasStagedChanges = not process.run({ config.gitCmd, "diff", "--cached", "--quiet" }).ok
	if hasStagedChanges then
		-- Argv array (not a shell string) so the spaces in the commit message and
		-- author config aren't word-split.
		local commit = process.run({
			config.gitCmd,
			"-c",
			`user.name={GIT_AUTHOR_NAME}`,
			"-c",
			`user.email={GIT_AUTHOR_EMAIL}`,
			"commit",
			"-m",
			`Publish {nextTag}`,
		}, { stdio = "inherit" })
		assert(commit.ok, commit.stderr)
	end

	run(config.gitCmd, { "push", "--force", "origin", branch })

	local server = process.env.GITHUB_SERVER_URL or "https://github.com"
	local releaseUrl = `{server}/{getRepoSlug()}/releases/tag/{nextTag}`
	local prTitle = `[AUTO-GENERATED] Publish {nextTag}`
	local template = (parser:get("template") :: string?) or DEFAULT_PR_TEMPLATE
	local prBody = template:gsub("{{version}}", nextVersion):gsub("{{releaseUrl}}", releaseUrl)

	-- Update the existing publish PR in place if there is one, otherwise open it.
	local list = process.run({
		config.ghCmd,
		"pr",
		"list",
		"--head",
		branch,
		"--base",
		base,
		"--state",
		"open",
		"--json",
		"number",
		"-q",
		".[0].number // empty",
	})
	assert(list.ok, list.stderr)
	local existing = list.stdout:gsub("%s+$", "")

	-- Argv arrays (not shell strings) so the spaces in the title and body survive.
	if existing == "" then
		local create = process.run(
			{ config.ghCmd, "pr", "create", "--base", base, "--head", branch, "--title", prTitle, "--body", prBody },
			{ stdio = "inherit" }
		)
		assert(create.ok, create.stderr)
		print(`Opened publish PR for {nextTag}`)
	else
		local edit = process.run(
			{ config.ghCmd, "pr", "edit", existing, "--title", prTitle, "--body", prBody },
			{ stdio = "inherit" }
		)
		assert(edit.ok, edit.stderr)
		print(`Updated publish PR #{existing} for {nextTag}`)
	end
end

local command: types.Command = {
	run = preparePr,
	title = title,
	summary = summary,
	parser = parser,
}

return command
