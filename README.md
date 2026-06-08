# flipbook-cli

Deploy [Flipbook](https://github.com/flipbook-labs/flipbook) storybook experiences to Roblox via Open Cloud.

## Installation

```sh
rokit add flipbook-labs/flipbook-cli
```

## Setup

1. Create a Roblox **experience** in Creator Hub.
2. Copy the **universe ID** and the **start place ID** (the place created with the experience, or your chosen root place).
3. Enable **Allow Copying** on the start place if you will create per-PR preview places (`CreatePlaceAsync` clones from it).
4. Set your Open Cloud API key (or store it as a GitHub Actions secret):

| Variable         | Description        |
| ---------------- | ------------------ |
| `ROBLOX_API_KEY` | Open Cloud API key |

The universe and target place are passed per command via `--universe-id` and (optionally) `--place-id`.

API key scopes: `universe.place.luau-execution-session:write`, `universe-places` write.

## Commands

### `deploy`

Publish a pre-built `.rbxl` place file to a named place in your universe, then inject the Flipbook runtime. The place is resolved by name, or created if it does not exist yet.

```sh
flipbook-cli deploy --universe-id 123 --place-name main --place-file out.rbxl
flipbook-cli deploy --universe-id 123 --place-name pr-42 --place-file out.rbxl
```

| Flag              | Description                                                                                 |
| ----------------- | ------------------------------------------------------------------------------------------- |
| `--place-name`    | **Required.** Name of the place to update or create for this deployment.                     |
| `--universe-id`   | **Required.** Universe to deploy to.                                                         |
| `--place-file`    | **Required.** Path to an `.rbxl` place file containing your storybooks and stories.          |
| `--api-key`       | Roblox API key. Falls back to the `ROBLOX_API_KEY` env var.                                  |
| `--place-id`      | Publish to a specific place ID instead of resolving by name. Disambiguates same-named places. |
| `--flipbook-rbxm` | Path to a local `Flipbook.rbxm` to use as the runtime. Defaults to the latest GitHub release. |

Each deploy:

- resolves `--place-name` to a place in the universe (creating it via `CreatePlaceAsync` from the start place if needed),
- publishes `--place-file` to that place, and
- injects `ReplicatedStorage.Flipbook` from the latest [GitHub release](https://github.com/flipbook-labs/flipbook/releases) (or `--flipbook-rbxm`), downloaded to `system.tmpdir()/flipbook-cli/`.

`ReplicatedStorage.Stories` (and the rest of the storybook) comes from whatever is in `--place-file`. Place lookup uses Roblox as the source of truth (by place name). No local place registry.

### `comment`

Post or update the storybook preview comment on a pull request. Resolves the place by name (same as deploy) to build the preview link.

```sh
flipbook-cli comment --pr 42 --universe-id 123 --place-name pr-42
```

| Flag                  | Description                                                          |
| --------------------- | ------------------------------------------------------------------ |
| `--pr`                | **Required.** Pull request number to comment on.                    |
| `--universe-id`       | **Required.** Universe the preview place lives in.                  |
| `--place-name`        | **Required.** Name of the deployed preview place.                  |
| `--api-key`           | Roblox API key. Falls back to the `ROBLOX_API_KEY` env var.        |
| `--github-token`      | GitHub token. Falls back to the `GITHUB_TOKEN` env var.            |
| `--github-repository` | `owner/repo`. Falls back to the `GITHUB_REPOSITORY` env var.       |

### `release`

Manage the project's own release lifecycle. The version in `loom.config.luau` is
the source of truth; these subcommands tag it, draft the GitHub release, attach
build artifacts, and prepare the next version-bump PR. The release workflow
([`.github/workflows/release.yml`](.github/workflows/release.yml)) is a thin
wrapper that runs these against [git-cliff](https://github.com/orhun/git-cliff)
and [`gh`](https://cli.github.com/) (authenticated via `GH_TOKEN`/`GITHUB_TOKEN`).

| Subcommand   | Description                                                                                      |
| ------------ | ------------------------------------------------------------------------------------------------ |
| `gate`       | Decide whether to publish the current version or prepare the next one. Prints the decision as JSON (`version`, `should_publish`, `has_changes`) for the caller to parse. Pass `--force-publish` to publish regardless of repo state. |
| `draft`      | Tag the current version's commit, push the tag, and open a draft GitHub release with git-cliff-generated notes. |
| `attach`     | Upload build artifacts to the draft release for a tag (skips non-draft releases).                |
| `prepare-pr` | Bump the version, regenerate `CHANGELOG.md`, and open/update the `publish-next-version` PR.       |

```sh
flipbook-cli release gate
flipbook-cli release draft --version 1.2.0
flipbook-cli release attach --tag v1.2.0 --files flipbook-cli-linux-x86_64.zip
flipbook-cli release prepare-pr --bump minor
```

## Environment variables

| Variable            | Description                                                          |
| ------------------- | ------------------------------------------------------------------- |
| `ROBLOX_API_KEY`    | Open Cloud API key; fallback for `--api-key` on every command        |
| `GITHUB_TOKEN`      | GitHub API auth for the Flipbook release fetch and `comment`         |
| `GITHUB_REPOSITORY` | `owner/repo`; fallback for `--github-repository` on `comment`        |

The release commands also honor command-path overrides: `FLIPBOOK_ROJO_CMD`, `FLIPBOOK_GIT_CMD`, `FLIPBOOK_GH_CMD`, and `FLIPBOOK_GIT_CLIFF_CMD` (default to `rojo`, `git`, `gh`, and `git-cliff`).
