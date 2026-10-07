@tool
extends "res://rookframe/ui/components/forms/text_area.gd"
## Phone density for the existing task multiline field relationship.
@export var silkbound := false
@export var compact := false:
	set(next):
		compact = next
		_refresh()

func _refresh() -> void:
	super._refresh()
	if not is_inside_tree():
		return
	add_theme_constant_override("separation", 3 if compact else 8)
	get_node(^"Label").add_theme_font_size_override("font_size", get_theme_constant("label_font_size") if has_theme_constant_override("label_font_size") else 11 if compact else 13)
	get_node(^"Help").visible = not compact and not help_text.is_empty() and error_text.is_empty()
	get_node(^"Editor").custom_minimum_size.y = get_theme_constant("editor_minimum_height") if has_theme_constant_override("editor_minimum_height") else 64 if compact else 152
	get_node(^"Editor").add_theme_font_size_override("font_size", get_theme_constant("editor_font_size") if has_theme_constant_override("editor_font_size") else 12 if compact else 15)
	var frame := get_node(^"Editor").get_theme_stylebox("normal").duplicate() as StyleBoxFlat
	frame.content_margin_top = 8 if compact else 14
	frame.content_margin_bottom = 8 if compact else 14
	frame.content_margin_left = 10 if compact else 14
	frame.content_margin_right = 10 if compact else 14
	get_node(^"Editor").add_theme_stylebox_override("normal", frame)

	if silkbound:
		preload("res://rookframe/ui/_internal/forms/silkbound_task_field.gd").apply(self,compact,true)
