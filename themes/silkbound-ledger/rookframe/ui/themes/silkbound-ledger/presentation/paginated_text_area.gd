@tool
extends RefCounted
const Appearance = preload("res://rookframe/ui/_internal/presentation/appearance.gd")




func _style_editor(control) -> void:
	Appearance.override_item(control._editor, "font_sizes", "font_size", 16 if control.compact else 20)
	Appearance.override_item(control._editor, "constants", "line_spacing", 6 if control.compact else 10)
