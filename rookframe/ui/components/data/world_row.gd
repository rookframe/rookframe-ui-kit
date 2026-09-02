@tool
extends Button

## Selectable record row with a leading semantic marker, identity and compact
## metadata, and a disclosure affordance. The caller owns selection policy.

@export var title := "World":
	set(value):
		title = value
		_refresh()

@export_multiline var detail_text := "":
	set(value):
		detail_text = value
		_refresh()

@export var selected := false:
	set(value):
		selected = value
		_refresh()


func _ready() -> void:
	_refresh()


func _refresh() -> void:
	if not is_inside_tree():
		return
	var normal_surface := get_node_or_null(^"NormalSurface") as Control
	var selected_surface := get_node_or_null(^"SelectedSurface") as Control
	var title_label := get_node_or_null(^"Content/Copy/Title") as Label
	var detail_label := get_node_or_null(^"Content/Copy/Detail") as Label
	if normal_surface != null:
		normal_surface.visible = not selected
	if selected_surface != null:
		selected_surface.visible = selected
	if title_label != null:
		title_label.text = title
	if detail_label != null:
		detail_label.text = detail_text
	accessibility_name = title
	accessibility_description = ("Selected. " if selected else "Not selected. ") + detail_text
