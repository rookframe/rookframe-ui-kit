@tool
extends RefCounted
const Appearance = preload("res://rookframe/ui/_internal/presentation/appearance.gd")




func _style_layout(control, header: MarginContainer) -> void:
	Appearance.override_item(header, "constants", "margin_left", (48 if control.compact else 76) if control.show_emblem else 18)
	Appearance.override_item(header, "constants", "margin_right", 20 if control.compact else 62)
	Appearance.override_item(control.get_node("Sections"), "constants", "margin_left", 8 if control.compact else 18)
	Appearance.override_item(control.get_node("Footer"), "constants", "margin_left", 28 if control.compact else 78)
	Appearance.override_item(control.get_node("Footer"), "constants", "margin_right", 8 if control.compact else 26)
	Appearance.override_item(control.get_node("Footer"), "constants", "margin_top", 4 if control.compact else 5)
