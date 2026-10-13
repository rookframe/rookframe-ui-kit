extends Texture2D
## Native PopupMenu supplies the checked row's position, including scrolling.
## Only its horizontal placement changes; radio semantics remain native.
var popup: WeakRef
var image: Texture2D
var trailing_inset := 0.0
var disabled_tint := Color.WHITE


func _get_width() -> int:
	return 0


func _get_height() -> int:
	return image.get_height() if image else 0


func _draw(canvas: RID, pos: Vector2, modulate: Color, transpose: bool) -> void:
	var menu := popup.get_ref() as PopupMenu if popup else null
	if not is_instance_valid(menu) or image == null:
		return
	var panel := menu.get_theme_stylebox("panel")
	var width := menu.size.x / menu.content_scale_factor - panel.get_minimum_size().x
	pos.x = trailing_inset if menu.is_layout_rtl() else width - trailing_inset - image.get_width()
	image.draw(canvas, pos, modulate * disabled_tint, transpose)
