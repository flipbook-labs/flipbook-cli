return {
	bump = "minor",
	category = "Changes",
	kind = "deploy",
	flags = { "Breaking" },
	summary = "Build the deployed place with Rojo, so a deploy isn't limited to about 8 MiB.",
	body = "Replace `--place-file` with `--stories`, an `.rbxm` that includes the packages your stories require, and install Rojo.",
}
