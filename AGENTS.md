## Cursor Cloud specific instructions

This is a **Luau** CLI project (`flipbook-cli`) built with the [Lute](https://github.com/luau-lang/lute) runtime and compiled to a native binary. Toolchain is managed by [Rokit](https://github.com/rojo-rbx/rokit).

### Key commands

| Action | Command |
|---|---|
| Install tools | `rokit install` (installs lute, rojo, rocale-cli, luau-lsp) |
| Set up type definitions | `lute setup` |
| Install deps + build binary | `lute run build` |
| Run tests | `lute test` |
| Static analysis (luau-lsp) | `lute run analyze` |
| Run the built CLI | `./build/flipbook-cli` |

### Caveats

- A `.env` file must exist in the project root for the CLI to start (it loads via `dotenv`). Copy from `.env.template` if missing: `cp .env.template .env`.
- `lute run build` must be run before `lute test` — the build step installs Loom packages into `packages/` which are required by both the binary and test files.
- `lute run analyze` exits non-zero on `main` due to pre-existing type errors in the codebase. This is expected.
- The `deploy`, `comment`, and `yank` commands require external Roblox/GitHub API credentials (`ROBLOX_API_KEY`, `ROBLOX_STORYBOOK_UNIVERSE_ID`, etc.). Without these, the CLI can only be tested via `--help` and the test suite.
- `selene` and `stylua` are referenced in config files (`selene.toml`, `stylua.toml`) but are **not** in `rokit.toml` or CI — they are optional local-only tools.
- Rokit tools must be trusted before first install. The update script handles this automatically with `rokit trust`.
