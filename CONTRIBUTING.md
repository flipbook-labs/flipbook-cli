# Contributing to FlipbookCli

## Setup

FlipbookCli uses [Rokit](https://github.com/rojo-rbx/rokit) for toolchain management.

```sh
rokit install
lute run install   # install the dependencies in pkg.luau
```

The repository is a Lute package workspace. The root [`pkg.luau`](pkg.luau) lists the packages under [`workspace/`](workspace), and each one declares its own dependencies in its own `pkg.luau`. The CLI lives in [`workspace/flipbook-cli`](workspace/flipbook-cli).

`lute run install` copies every package's dependencies into the gitignored `.lpm/` folder, which code requires through the `@lpm` alias. It also fetches the shared [agent-skills](https://github.com/flipbook-labs/agent-skills) library that [`AGENTS.md`](AGENTS.md) routes agents to. That library is a dev dependency, so it stays out of the compiled binary.

## Checks

```sh
lute run analyze   # run the stylua and luau-lsp checks
lute run build     # compile the flipbook-cli binary into build/
lute test          # run the *.spec.luau test suite
```

Tests live in `*.spec.luau` files beside the code they cover.

## Changes

Add a [`.changes/`](.changes) entry for each user-facing change. The [`.changes/README.md`](.changes/README.md) lists the fields and kinds.

## Releasing

Releases are handled by [changewrite](https://github.com/flipbook-labs/changewrite), which bundles the release lifecycle into one GitHub Action. The release workflow ([`.github/workflows/release.yml`](.github/workflows/release.yml)) builds the binaries and hands the version source, [`changewrite.luau`](changewrite.luau) mirrored to [`workspace/flipbook-cli/pkg.luau`](workspace/flipbook-cli/pkg.luau), to the action. The action attaches the binaries to the draft release through its `post-draft-hook`.
