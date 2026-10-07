extends HBoxContainer

func _draw() -> void:
	draw_line(Vector2(0, size.y - 1), Vector2(size.x, size.y - 1), Color("3e4346"))
