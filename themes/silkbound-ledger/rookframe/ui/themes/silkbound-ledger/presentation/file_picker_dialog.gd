@tool
extends RefCounted
const Appearance = preload("res://rookframe/ui/_internal/presentation/appearance.gd")




func _style_spacing(control, compact: bool) -> void:
	Appearance.override_item(control.get_node(^"Shell/Content"), "constants", &"separation", 8 if compact else 16)
