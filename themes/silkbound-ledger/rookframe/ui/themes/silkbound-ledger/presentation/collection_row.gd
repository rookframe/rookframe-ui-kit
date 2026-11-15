@tool
extends RefCounted
const Appearance = preload("res://rookframe/ui/_internal/presentation/appearance.gd")
const Tokens = preload("res://rookframe/ui/theme/silkbound_tokens.gd")




func _draw(control) -> void:
	control.draw_line(Vector2(0, control.size.y - 1), Vector2(control.size.x, control.size.y - 1), Tokens.color(&"divider"))
