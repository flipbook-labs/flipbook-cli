# FlipbookCli

FlipbookCli publishes a place file of your storybooks to a Roblox experience and injects the [Flipbook](https://flipbook-labs.github.io/flipbook) runtime into it. It can run on your machine or in CI, and it can post a preview link on a pull request so reviewers can open each change in Roblox.

## Install

Install with [Rokit](https://github.com/rojo-rbx/rokit):

```sh
rokit add flipbook-labs/flipbook-cli
```

Rokit downloads the binary for your platform from the latest release.

## Use

Set up once in Roblox:

1. Create an experience in Creator Hub.
2. Note the universe ID and the ID of its start place, the place created with the experience or your root place.
3. Enable **Allow Copying** on the start place. A deploy creates a new place by copying it.
4. Create an Open Cloud API key restricted to your experience, with these permissions:
   - `universe-places:write`
   - `universe.place.luau-execution-session:read`
   - `universe.place.luau-execution-session:write`

Then deploy a place file that holds your storybooks. Build the file with your usual tooling, such as Rojo.

```sh
flipbook-cli deploy --universe-id 123 --place-name "Flipbook Stories 42" --place-file out.rbxl
```

The last lines of the output name the place and its preview link:

```text
Deployed storybook "Flipbook Stories 42" to place 123456789
View: https://roblox.com/games/123456789
Launch: https://www.roblox.com/games/start?placeId=123456789
```

To post that link on the pull request, run `comment` with the same place name:

```sh
flipbook-cli comment --pr 42 --universe-id 123 --place-name "Flipbook Stories 42" --launch-data '{"search":"Button|Dialog"}'
```

Running `comment` again on the same pull request edits the comment it posted earlier.

## Commands

### deploy

Publishes `--place-file` to a place in your universe, then injects the Flipbook runtime from the latest [GitHub release](https://github.com/flipbook-labs/flipbook/releases). The place is found by name in Roblox, and it is created when no place has that name. The CLI keeps no local state.

The release download is unauthenticated unless `GITHUB_TOKEN` is set. Set it on shared CI runners, which can hit GitHub's rate limit for anonymous requests.

| Flag              | Description                                                                                                  |
| ----------------- | ------------------------------------------------------------------------------------------------------------ |
| `--place-name`    | **Required.** Name of the place to update, or to create.                                                     |
| `--universe-id`   | **Required.** Universe to deploy to.                                                                         |
| `--place-file`    | **Required.** Path to an `.rbxl` file containing your storybooks and stories.                                |
| `--place-id`      | Publish to this place ID instead of resolving `--place-name`. Use it to tell apart places that share a name. |
| `--flipbook-rbxm` | Path to a local `Flipbook.rbxm` to use as the runtime, instead of the latest release.                        |
| `--api-key`       | Open Cloud API key. Falls back to `ROBLOX_API_KEY`.                                                          |

### comment

Posts or updates the preview comment on a pull request. The place named by `--place-name` supplies the links.

| Flag                  | Description                                                |
| --------------------- | ---------------------------------------------------------- |
| `--pr`                | **Required.** Pull request number to comment on.           |
| `--universe-id`       | **Required.** Universe the preview place lives in.         |
| `--place-name`        | **Required.** Name of the deployed preview place.          |
| `--launch-data`       | JSON object to include as launch data in the preview link. |
| `--api-key`           | Open Cloud API key. Falls back to `ROBLOX_API_KEY`.        |
| `--github-token`      | GitHub token. Falls back to `GITHUB_TOKEN`.                |
| `--github-repository` | `owner/repo`. Falls back to `GITHUB_REPOSITORY`.           |

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

MIT.
