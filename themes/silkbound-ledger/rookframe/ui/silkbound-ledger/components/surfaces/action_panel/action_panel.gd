@tool
extends "res://rookframe/ui/components/surfaces/action_panel/action_panel.gd"

func _style_layout(header: MarginContainer) -> void:
	header.add_theme_constant_override("margin_left", (48 if compact else 76) if show_emblem else 18)
	header.add_theme_constant_override("margin_right", 20 if compact else 62)
	get_node("Sections").add_theme_constant_override("margin_left", 8 if compact else 18)
	get_node("Footer").add_theme_constant_override("margin_left", 28 if compact else 78)
	get_node("Footer").add_theme_constant_override("margin_right", 8 if compact else 26)
	get_node("Footer").add_theme_constant_override("margin_top", 4 if compact else 5)
