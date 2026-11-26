local CHANGEWRITE = "https://github.com/flipbook-labs/changewrite"

return {
	package = {
		name = "svg-buttons",
		version = "0.7.0",
		dependencies = {
			batteries = {
				rev = "v1.0.1-nightly.20261115",
				sourceKind = "github",
				source = "https://github.com/luau-lang/lute",
				target = "batteries",
			},
			png = { rev = "v0.16.0", sourceKind = "github", source = CHANGEWRITE, target = "workspace/png" },
			truetype = { rev = "v0.16.0", sourceKind = "github", source = CHANGEWRITE, target = "workspace/truetype" },
			vector = { rev = "v0.16.0", sourceKind = "github", source = CHANGEWRITE, target = "workspace/vector" },
		},
	},
}
