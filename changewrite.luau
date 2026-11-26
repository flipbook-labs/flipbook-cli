return {
	categories = { "Features", "Changes", "Fixes", "Dependencies", "Internal" },
	collapsed = { "Dependencies", "Internal" },
	version = {
		current = "0.6.0",
		mirror = {
			{ file = "workspace/flipbook-cli/pkg.luau" },
			{ file = "workspace/svg-buttons/pkg.luau" },
		},
	},
	kind = {
		release = { text = "Release", color = "#94606f" },
		build = { text = "Build", color = "#5a7396" },
		ci = { text = "CI", color = "#75659a" },
		cli = { text = "CLI", color = "#0e7490" },
		comment = { text = "Comment", color = "#bf3989" },
		contributing = { text = "Contributing", color = "#5f7f55" },
		deploy = { text = "Deploy", color = "#5b5bd6" },
		docs = { text = "Docs", color = "#8a5a2b" },
		packages = { text = "Packages", color = "#7a7444" },
		tooling = { text = "Tooling", color = "#4e8079" },
	},
}
