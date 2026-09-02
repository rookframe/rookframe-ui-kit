@tool
extends PanelContainer

## Package identity with role, version, and selection status. The component
## contains no Package policy; callers provide the displayed data and state.

@export var package_name := "Package":
	set(value):
		package_name = value
		_refresh()

@export_multiline var detail_text := "":
	set(value):
		detail_text = value
		_refresh()

@export var selected := false:
	set(value):
		selected = value
		_refresh()

@export var locked := false:
	set(value):
		locked = value
		_refresh()

@export var locked_state_label := "INCLUDED":
	set(value):
		locked_state_label = value
		_refresh()


func _ready() -> void:
	_refresh()


func _refresh() -> void:
	if not is_inside_tree():
		return
	var marker := get_node_or_null(^"Margin/Content/Marker") as Label
	var name_label := get_node_or_null(^"Margin/Content/Copy/Name") as Label
	var detail_label := get_node_or_null(^"Margin/Content/Copy/Detail") as Label
	var state_label := get_node_or_null(^"Margin/Content/State") as Label
	if marker != null:
		marker.text = "◆" if locked and selected else ("✓" if selected else "□")
		marker.theme_type_variation = &"RookframeStatus" if selected else &"RookframeMeta"
	if name_label != null:
		name_label.text = package_name
	if detail_label != null:
		detail_label.text = detail_text
		detail_label.visible = not detail_text.is_empty()
	if state_label != null:
		state_label.text = locked_state_label if locked else ("SELECTED" if selected else "ADD")
		state_label.theme_type_variation = &"RookframeStatus" if selected else &"RookframeMeta"
	accessibility_name = package_name
	accessibility_description = detail_text
