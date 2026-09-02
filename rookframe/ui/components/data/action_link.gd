@tool
extends Button

## Inline navigation action with a separate label, connecting rule, and arrow head.
## The caller owns action policy and connects the inherited pressed signal.

@export var title := "Action":
	set(value):
		title = value
		_refresh()

@export_range(0.0, 4096.0, 1.0) var title_lane_width := 150.0:
	set(value):
		title_lane_width = maxf(value, 0.0)
		_refresh()

@export_range(8, 72, 1) var title_font_size := 15:
	set(value):
		title_font_size = clampi(value, 8, 72)
		_refresh()


func _ready() -> void:
	_refresh()


func _refresh() -> void:
	if not is_inside_tree():
		return
	var title_label := get_node_or_null(^"Content/Title") as Label
	if title_label != null:
		title_label.text = title
		title_label.custom_minimum_size.x = title_lane_width
		title_label.add_theme_font_size_override(&"font_size", title_font_size)
	accessibility_name = title
	accessibility_description = "Navigation action"
