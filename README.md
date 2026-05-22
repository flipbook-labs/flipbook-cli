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
4. Set `ROBLOX_API_KEY` (or pass `--api-key` on each command). Use `--universe-id` and `--place-id` on deploy, yank, and comment.

API key scopes: `universe.place.luau-execution-session:write`, `universe-places` write.

## Commands

### `deploy`

Build a place (Rojo project generated at deploy time), resolve or create a named place, and publish.

```sh
flipbook-cli deploy --name main --universe-id <id> --place-id <id>
flipbook-cli deploy --name pr-42 --universe-id <id> --place-id <id> --stories ./out/stories.rbxm
flipbook-cli deploy --name main --dry-run out.rbxl
```

| Flag              | Description                                                                   |
| ----------------- | ----------------------------------------------------------------------------- |
| `--name`          | Place name (`main` → start place; other names resolve/create in the universe) |
| `--universe-id`   | Experience (universe) ID; required for publish                                |
| `--place-id`      | Root place ID; required for publish                                           |
| `--api-key`, `-k` | Open Cloud API key (default: `ROBLOX_API_KEY`)                                |
| `--stories`       | Optional `.rbxm` or directory mounted as `ReplicatedStorage.Stories`          |
| `--flipbook-rbxm` | Path to a local `Flipbook.rbxm` (skips GitHub download)                       |
| `--dry-run`       | Write `.rbxl` locally only; skip Open Cloud publish                           |

Each deploy produces a place with:

- `ReplicatedStorage.Flipbook` — `Flipbook.rbxm` from the latest [GitHub release](https://github.com/flipbook-labs/flipbook/releases) (cached under `system.tmpdir()/flipbook-cli/`)
- `ReplicatedStorage.Stories` — optional story payload (`.rbxm` or directory)

Place lookup uses Roblox as the source of truth (by place name). No local place registry.

### `comment`

Post or update a PR preview comment. Resolves the place by name via Luau Execution (same as deploy).

```sh
flipbook-cli comment --pr 42 --universe-id <id> --place-id <id> --name pr-42
```

### `yank`

Publish an empty place to clear a closed PR preview. Roblox does not expose place deletion; this overwrites the place contents.

```sh
flipbook-cli yank --name pr-42 --universe-id <id> --place-id <id>
```

## Environment variables

| Variable            | Description                                               |
| ------------------- | --------------------------------------------------------- |
| `ROBLOX_API_KEY`    | Open Cloud API key (or use `--api-key` / `-k`)            |
| `GITHUB_TOKEN`      | Optional; GitHub API auth for release fetch and `comment` |
| `GITHUB_REPOSITORY` | For `comment`                                             |

Universe and place IDs are passed via `--universe-id` and `--place-id`, not environment variables.
