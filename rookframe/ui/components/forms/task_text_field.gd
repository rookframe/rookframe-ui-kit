@tool
extends "res://rookframe/ui/components/forms/text_field.gd"
## Phone density for the existing task field relationship.
@export var compact := false:
	set(next):
		compact = next
		_refresh()

func _refresh() -> void:
	super._refresh()
	if not is_inside_tree():
		return
	add_theme_constant_override("separation", 3 if compact else 8)
	get_node(^"Label").add_theme_font_size_override("font_size", 11 if compact else 13)
	get_node(^"Help").visible = not compact and not help_text.is_empty() and error_text.is_empty()
	get_node(^"Editor").custom_minimum_size.y = 44 if compact else 48
	get_node(^"Editor").add_theme_font_size_override("font_size", 14 if compact else 15)
	var frame := get_node(^"Editor").get_theme_stylebox("normal").duplicate() as StyleBoxFlat
	frame.content_margin_top = 7 if compact else 14
	frame.content_margin_bottom = 7 if compact else 14
	frame.content_margin_left = 10 if compact else 14
	frame.content_margin_right = 10 if compact else 14
	get_node(^"Editor").add_theme_stylebox_override("normal", frame)
