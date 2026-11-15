@tool
extends RefCounted
const Appearance = preload("res://rookframe/ui/_internal/presentation/appearance.gd")
const Tokens = preload("res://rookframe/ui/theme/silkbound_tokens.gd")




func _state_icon_color(control) -> Color:
	return Tokens.color(&"pictogram")
