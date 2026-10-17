@tool
extends RefCounted
const Appearance = preload("res://rookframe/ui/_internal/presentation/appearance.gd")




func _draw(control) -> void:
	control.draw_line(Vector2(0, control.size.y - 1), Vector2(control.size.x, control.size.y - 1), Color("3e4346"))
