@tool
extends RefCounted
## Editor density values; visual materials come from the current menu themes.
static func geometry() -> Dictionary:
	return {
		"editor.height": 64, "editor.height.compact": 52,
		"editor.icon_size": 24, "editor.icon_size.compact": 22,
		"editor.icon_gap": 10, "editor.tool_gap": 6, "editor.rule_gap": 8,
		"editor.font_size": 22, "editor.font_size.compact": 19,
		"editor.heading.size": 26, "editor.heading.size.compact": 22,
		"editor.body.size": 20, "editor.body.size.compact": 18,
		"editor.meta.size": 14, "editor.meta.size.compact": 13,
		"editor.accent.size": 18, "editor.accent.size.compact": 16,
	}
