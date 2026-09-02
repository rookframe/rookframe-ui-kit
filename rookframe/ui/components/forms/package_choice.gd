@tool
extends Button

## Complete multi-select Package target. Package copy and selection semantics
## are data; callers keep ownership of Package policy and persistence.

@export var package_name := "Package":
	set(value):
		package_name = value
		_refresh()

@export_multiline var detail_text := "":
	set(value):
		detail_text = value
		_refresh()

@export var action_label := "ADD":
	set(value):
		action_label = value
		_refresh()


func _ready() -> void:
	if not toggled.is_connected(_on_toggled):
		toggled.connect(_on_toggled)
	_refresh()


func _on_toggled(_selected: bool) -> void:
	_refresh()


func _refresh() -> void:
	if not is_inside_tree():
		return
	var marker := get_node_or_null(^"Content/Marker") as Control
	var selected_marker := get_node_or_null(^"Content/SelectedMarker") as Control
	var name_label := get_node_or_null(^"Content/Copy/Name") as Label
	var detail_label := get_node_or_null(^"Content/Copy/Detail") as Label
	var state_label := get_node_or_null(^"Content/State") as Label
	if marker != null:
		marker.visible = not button_pressed
	if selected_marker != null:
		selected_marker.visible = button_pressed
	if name_label != null:
		name_label.text = package_name
	if detail_label != null:
		detail_label.text = detail_text
		detail_label.visible = not detail_text.is_empty()
	if state_label != null:
		state_label.text = "INCLUDED" if button_pressed else action_label
		state_label.theme_type_variation = &"RookframeStatus" if button_pressed else &"RookframeMeta"
	accessibility_name = package_name
	accessibility_description = ("Included. " if button_pressed else "Not included. ") + detail_text
