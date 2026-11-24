return {
	bump = "minor",
	category = "Changes",
	kind = "release",
	summary = "Releases are now handled by the changewrite action, which bundles the whole release lifecycle into a single workflow step.",
	body = "The action covers the gate, draft, attach, publish, and version-bump PR steps, replacing the bespoke `release` command and its multi-job workflow.",
}
