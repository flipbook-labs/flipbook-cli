local cli = require("@batteries/cli")
local process = require("@std/process")

local cliff = require("@root/release/cliff")
local exec = require("@root/release/exec")
local git = require("@root/release/git")
local types = require("@root/cli/types")
local version = require("@root/release/version")

local title = "release prepare-pr"
local summary = "Bump the version, regenerate the changelog, and open/update the publish PR."

-- A stable identity for the publish commit so it isn't attributed to whoever's
-- credentials happen to be configured in the runner.
local GIT_AUTHOR_NAME = "github-actions[bot]"
local GIT_AUTHOR_EMAIL = "41898282+github-actions[bot]@users.noreply.github.com"

local parser = cli.parser()
parser:add("bump", "option", {
	help = "Which semver component to bump when preparing the next release (minor | patch).",
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
parser:add("help", "flag", {
	help = "Show this help message",
})

local function repoSlug(): string
	-- GITHUB_REPOSITORY is set in Actions; fall back to gh for local runs.
	return process.env.GITHUB_REPOSITORY
		or exec.capture({ "gh", "repo", "view", "--json", "nameWithOwner", "-q", ".nameWithOwner" })
end

local function run()
	local current = version.read()
	local bumpKind: version.BumpKind = if parser:get("bump") == "patch" then "patch" else "minor"

	-- If the current version is already tagged, bump to the next one; otherwise
	-- the version hasn't been released yet, so prepare a PR for it as-is.
	local nextVersion = if git.tagExists(`v{current}`) then version.bump(current, bumpKind) else current
	local nextTag = `v{nextVersion}`

	version.write(nextVersion)
	cliff.writeChangelog(nextTag, "CHANGELOG.md")

	local base = parser:get("base") :: string
	local branch = parser:get("branch") :: string

	exec.check({ "git", "switch", "-C", branch })
	exec.check({ "git", "add", "CHANGELOG.md", "loom.config.luau" })
	exec.check({
		"git",
		"-c",
		`user.name={GIT_AUTHOR_NAME}`,
		"-c",
		`user.email={GIT_AUTHOR_EMAIL}`,
		"commit",
		"-m",
		`Publish {nextTag}`,
	})
	exec.check({ "git", "push", "--force", "origin", branch })

	local server = process.env.GITHUB_SERVER_URL or "https://github.com"
	local releaseUrl = `{server}/{repoSlug()}/releases/tag/{nextTag}`
	local prTitle = `[AUTO-GENERATED] Publish {nextTag}`
	local body = table.concat({
		"This PR prepares the next release by bumping the version and updating the changelog.",
		"",
		"Merging this PR will:",
		"",
		`1. Create and push tag \`{nextTag}\``,
		"2. Create a draft GitHub release for that tag",
		"3. Build the project and attach release assets to the draft release",
		"",
		"Next release will be available here:",
		releaseUrl,
	}, "\n")

	-- Update the existing publish PR in place if there is one, otherwise open it.
	local existing = exec.capture({
		"gh",
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
		".[0].number",
	})

	if existing == "" then
		exec.check({ "gh", "pr", "create", "--base", base, "--head", branch, "--title", prTitle, "--body", body })
		print(`Opened publish PR for {nextTag}`)
	else
		exec.check({ "gh", "pr", "edit", existing, "--title", prTitle, "--body", body })
		print(`Updated publish PR #{existing} for {nextTag}`)
	end
end

local command: types.Command = {
	run = run,
	title = title,
	summary = summary,
	parser = parser,
}

return command
