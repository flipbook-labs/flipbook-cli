# Changelog

All notable changes to this project will be documented in this file.


## v0.6.0

### Changes

- Open the publish and debug PRs as drafts ([708c279](https://github.com/flipbook-labs/flipbook-cli/commit/708c2794e40fa3a344492c3a7f4dc3bc0e8bf0d9))

- Fix release PR prep parsing and silence app-token deprecation ([88f4683](https://github.com/flipbook-labs/flipbook-cli/commit/88f46833210147d8327ca5efe94aad7314348161))

- Automate release publishing and preview release notes in the publish PR ([a23f79e](https://github.com/flipbook-labs/flipbook-cli/commit/a23f79e4f9b2d55e156c9479b1531f59989fb34d))



## v0.5.0

### Changes

- Restore create-pull-request action; strip prepare-pr to file edits + JSON output (#41) ([8ff110b](https://github.com/flipbook-labs/flipbook-cli/commit/8ff110b48c07bd0285ab86c95797384b4060e462))

- Update README for correctness and remove the yank command (#42) ([b93dae6](https://github.com/flipbook-labs/flipbook-cli/commit/b93dae6c69d5550bcfdd3c0c80309928f50c2385))

- Explain the likely cause when publishing returns 409 Conflict (#40) ([da2f3be](https://github.com/flipbook-labs/flipbook-cli/commit/da2f3be322594c5e34713bb0ae5a643f21e58503))

- Add `flipbook-cli release` subcommands for the release lifecycle (#38) ([6976536](https://github.com/flipbook-labs/flipbook-cli/commit/6976536b7a9d01df521c6ba310be902d2accef1a))



## v0.4.0

### Changes

- Fix broken release (#35) ([bb04a32](https://github.com/flipbook-labs/flipbook-cli/commit/bb04a321a6c7472762bd36691a50e978b9245c99))

- Generate release notes for just the current release (#34) ([3936620](https://github.com/flipbook-labs/flipbook-cli/commit/3936620af5ef92d25d5b9801d9dbcd1c52128208))



## v0.3.0

### Changes

- Run StyLua on the codebase (#31) ([5a9d599](https://github.com/flipbook-labs/flipbook-cli/commit/5a9d5993ac0b550d420c51324e1e06e31ac01880))

- Tag the publish commit instead of whatever tripped the gate (#32) ([dfd8cdc](https://github.com/flipbook-labs/flipbook-cli/commit/dfd8cdc08ea2b9b8b00b8a11d15a4d26ad891cb6))

- Inject Flipbook via Open Cloud binary input instead of a Rojo overlay (#30) ([026246a](https://github.com/flipbook-labs/flipbook-cli/commit/026246ab01e5f8df1602871d4c384a9405d97a0e))



## v0.2.0

### Changes

- Harden the release workflow gate and tolerate Windows build failures (#26) ([a2dd889](https://github.com/flipbook-labs/flipbook-cli/commit/a2dd8892fa1686905319132a01836935670061dd))

- Finish up the `comment` command so we can use it in Flipbook (#24) ([de52c3a](https://github.com/flipbook-labs/flipbook-cli/commit/de52c3a1f612414002dabaf69f51eb9f31575824))

- Skip publish tag push when tag already exists on origin (#23) ([628f85a](https://github.com/flipbook-labs/flipbook-cli/commit/628f85a88e966aa1a498c7dc2f87b5613bfc598b))

- Try and fix the release workflow yet again (#21) ([48fb606](https://github.com/flipbook-labs/flipbook-cli/commit/48fb606a1aee643b2781fef8f4d9e428f23798c6))



## v0.1.0

### Changes

- Fix release automation (#17) ([de234d5](https://github.com/flipbook-labs/flipbook-cli/commit/de234d5d92c1c5340e8fdf2c910f5c44e02a4626))

- Fix the PR release creation workflow (#14) ([075cccd](https://github.com/flipbook-labs/flipbook-cli/commit/075cccde28b55a10d58aa788b93f5204b47d6420))

- Add release PR automation with git-cliff (#12) ([c4b1851](https://github.com/flipbook-labs/flipbook-cli/commit/c4b1851ef228a0e9082ce621c896a76575b8de8f))

- Add cross-platform release workflow (#9) ([0086d29](https://github.com/flipbook-labs/flipbook-cli/commit/0086d2941e01487d890d6f92b332b8f656643e02))

- Get deployments working (#5) ([bba94d6](https://github.com/flipbook-labs/flipbook-cli/commit/bba94d62d82b8d495a5e71c7973a81203f57cf7a))

- Fix arguments getting parsed twice (#10) ([25b19c8](https://github.com/flipbook-labs/flipbook-cli/commit/25b19c849ac648b2434e29d5053a7cfa9d670326))

- Organize HTTP helpers under requests/ with Async naming (#7) ([5730697](https://github.com/flipbook-labs/flipbook-cli/commit/5730697fee77bad534dda10cc73e121867b69801))

- Build help text from data, not docstrings (#3) ([6848064](https://github.com/flipbook-labs/flipbook-cli/commit/6848064c1f0a8dc95b9eda479987f5c4ed18f217))

- Display help for malformed commands (#2) ([0652674](https://github.com/flipbook-labs/flipbook-cli/commit/06526748c7fa5a2d977090df6c4ace5781de35c7))

- Bump lute version (#1) ([7f6137f](https://github.com/flipbook-labs/flipbook-cli/commit/7f6137ff11e6f81e83159a649b919883c865fbe5))

- Remove another leftover env var ([923f99f](https://github.com/flipbook-labs/flipbook-cli/commit/923f99f99e6aba73118792c79bb115d9ff82bb07))

- Update formatting across commands ([efdece8](https://github.com/flipbook-labs/flipbook-cli/commit/efdece87303f5e7a5d284616aa663e04d9734de1))

- Rename startPlaceId variable to placeId ([b50d9af](https://github.com/flipbook-labs/flipbook-cli/commit/b50d9aff37324f111957ca1b2bfbccb567a3ea56))

- Hoist up constants ([87117bc](https://github.com/flipbook-labs/flipbook-cli/commit/87117bc2e54d02a2d2b386fc3458bcd4aba7edef))

- Remove extraneous environment variables ([14e3131](https://github.com/flipbook-labs/flipbook-cli/commit/14e3131035bbb3b1cc58adc022ea489ce5c26eb9))

- Update README ([bd10b20](https://github.com/flipbook-labs/flipbook-cli/commit/bd10b203c1f01189eecb4f8b15080ecb3426f768))

- Update comment command to resolve place by name ([82e03d8](https://github.com/flipbook-labs/flipbook-cli/commit/82e03d803705a588a51a5b0d5c070bb74a81f3ec))

- Replace prune command with yank ([854c73d](https://github.com/flipbook-labs/flipbook-cli/commit/854c73d334b222d5a7adba53fdb3ccae571b82e6))

- Refactor deploy to Open Cloud publish model ([7ca506c](https://github.com/flipbook-labs/flipbook-cli/commit/7ca506ca62d164bae110d0cd192e2c948f39e85d))

- Give a home to project constants ([c57dbac](https://github.com/flipbook-labs/flipbook-cli/commit/c57dbac8a61b0a5460f340727bafb65fc1cdf6f4))

- Fill out basics for publicizing ([aef1dc6](https://github.com/flipbook-labs/flipbook-cli/commit/aef1dc6622216e67080b73f6d0773b88cd475904))

- Bundle up dependencies when compiling ([d925160](https://github.com/flipbook-labs/flipbook-cli/commit/d9251607b647e9d22bb33bdbe1a6a5f4482c1715))

- Add CI workflow and refactor deployment commands for flipbook-cli ([5b3b5ac](https://github.com/flipbook-labs/flipbook-cli/commit/5b3b5ac63fe9f8dcb71f09815acb48aabebb35eb))

- Initial commit ([940f691](https://github.com/flipbook-labs/flipbook-cli/commit/940f69186520dafb5a3ab4819cfa7b094a8ef38b))

