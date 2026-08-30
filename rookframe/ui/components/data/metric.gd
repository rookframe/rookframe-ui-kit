@tool
extends PanelContainer

## One equal-priority metric cell with an optional detail and action lane.

@export var label_text := "Metric":
	set(value):
		label_text = value
		_refresh()

@export var value_text := "Value":
	set(value):
		value_text = value
		_refresh()

@export_multiline var detail_text := "":
	set(value):
		detail_text = value
		_refresh()


func _ready() -> void:
	_refresh()


func get_action_slot() -> Container:
	return get_node(^"Content/ActionSlot") as Container


func _refresh() -> void:
	if not is_inside_tree():
		return
	var label := get_node_or_null(^"Content/Label") as Label
	var value := get_node_or_null(^"Content/Value") as Label
	var detail := get_node_or_null(^"Content/Detail") as Label
	if label != null:
		label.text = label_text
	if value != null:
		value.text = value_text
	if detail != null:
		detail.text = detail_text
		detail.visible = not detail_text.is_empty()
	accessibility_name = "%s: %s" % [label_text, value_text]
	accessibility_description = detail_text
