return {
	package = {
		name = "flipbook-cli",
		version = "0.4.0",
		dependencies = {
			["flipbook-batteries"] = {
				rev = "v0.10.1",
				sourceKind = "github",
				source = "https://github.com/flipbook-labs/flipbook-batteries",
			},
			["lute"] = {
				rev = "v1.0.1-nightly.20260611",
				sourceKind = "github",
				source = "https://github.com/luau-lang/lute",
			},
			["dotenv"] = {
				rev = "v0.1.0",
				sourceKind = "github",
				source = "https://github.com/erlcx/lute-dotenv",
			},
		},
	},
}
