@tool
extends PanelContainer

## Compact labelled fact row for a stable key/value relationship.

@export var key_text := "Key":
	set(value):
		key_text = value
		_refresh()

@export_multiline var value_text := "":
	set(value):
		value_text = value
		_refresh()


func _ready() -> void:
	_refresh()


func _refresh() -> void:
	if not is_inside_tree():
		return
	var key := get_node_or_null(^"Content/Key") as Label
	var value := get_node_or_null(^"Content/Value") as Label
	if key != null:
		key.text = key_text
	if value != null:
		value.text = value_text
		value.visible = not value_text.is_empty()
	accessibility_name = key_text
	accessibility_description = value_text
