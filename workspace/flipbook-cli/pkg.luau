return {
	package = {
		name = "flipbook-cli",
		version = "0.6.0",
		dependencies = {
			["svg-buttons"] = { sourceKind = "path", source = "../svg-buttons" },
			["flipbook-batteries"] = {
				rev = "v0.13.1",
				sourceKind = "github",
				source = "https://github.com/flipbook-labs/flipbook-batteries",
			},
			batteries = {
				rev = "v1.0.1-nightly.20261115",
				sourceKind = "github",
				source = "https://github.com/luau-lang/lute",
				target = "batteries",
			},
			["luau-execution"] = {
				rev = "v0.2.0",
				sourceKind = "github",
				source = "https://github.com/flipbook-labs/open-cloud",
				target = "workspace/luau-execution",
			},
			places = {
				rev = "v0.2.0",
				sourceKind = "github",
				source = "https://github.com/flipbook-labs/open-cloud",
				target = "workspace/places",
			},
			["openapi-lute-transport"] = {
				rev = "v0.1.0",
				sourceKind = "github",
				source = "https://github.com/flipbook-labs/openapi-luau",
				target = "workspace/openapi-lute-transport",
			},
		},
	},
}
