# flipbook-cli

Deploy [Flipbook](https://github.com/flipbook-labs/flipbook) storybooks to Roblox Open Cloud for pull request previews.

## Installation

Install with [Rokit](https://github.com/rojo-rbx/rokit):

```sh
rokit add flipbook-labs/flipbook-cli
```

## Usage

```
flipbook-cli <command> [options]
```

### Commands

#### `deploy`

Build and deploy a storybook for a pull request.

```
flipbook-cli deploy [options]
```

| Flag                 | Description                                                |
| -------------------- | ---------------------------------------------------------- |
| `--pr <number>`      | Pull request number (required)                             |
| `--universe-id <id>` | Roblox Universe ID (or set `ROBLOX_STORYBOOK_UNIVERSE_ID`) |
| `--place-id <id>`    | Roblox Place ID (or set `ROBLOX_STORYBOOK_PLACE_ID`)       |

| Environment Variable           | Description                                                         |
| ------------------------------ | ------------------------------------------------------------------- |
| `ROBLOX_API_KEY`               | Roblox API key (required)                                           |
| `ROBLOX_STORYBOOK_UNIVERSE_ID` | Fallback for `--universe-id`                                        |
| `ROBLOX_STORYBOOK_PLACE_ID`    | Fallback for `--place-id`                                           |
| `GITHUB_TOKEN`                 | GitHub token (enables runtime upgrade checks when set)              |
| `GITHUB_REPOSITORY`            | GitHub repository, e.g. `owner/repo` (required with `GITHUB_TOKEN`) |

#### `prune`

Remove the storybook for a closed or merged pull request.

```
flipbook-cli prune [options]
```

| Flag                 | Description                                                |
| -------------------- | ---------------------------------------------------------- |
| `--pr <number>`      | Pull request number (required)                             |
| `--universe-id <id>` | Roblox Universe ID (or set `ROBLOX_STORYBOOK_UNIVERSE_ID`) |
| `--place-id <id>`    | Roblox Place ID (or set `ROBLOX_STORYBOOK_PLACE_ID`)       |

| Environment Variable           | Description                  |
| ------------------------------ | ---------------------------- |
| `ROBLOX_API_KEY`               | Roblox API key               |
| `ROBLOX_STORYBOOK_UNIVERSE_ID` | Fallback for `--universe-id` |
| `ROBLOX_STORYBOOK_PLACE_ID`    | Fallback for `--place-id`    |

#### `comment`

Post or update the storybook preview comment on a pull request.

```
flipbook-cli comment [options]
```

| Flag              | Description                                          |
| ----------------- | ---------------------------------------------------- |
| `--pr <number>`   | Pull request number (required)                       |
| `--place-id <id>` | Roblox Place ID (or set `ROBLOX_STORYBOOK_PLACE_ID`) |

| Environment Variable        | Description                       |
| --------------------------- | --------------------------------- |
| `ROBLOX_STORYBOOK_PLACE_ID` | Fallback for `--place-id`         |
| `GITHUB_TOKEN`              | GitHub token for posting comments |
| `GITHUB_REPOSITORY`         | GitHub repository (`owner/repo`)  |
