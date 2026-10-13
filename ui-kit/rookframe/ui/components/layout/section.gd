@tool
extends PanelContainer

## Framed section with a width-stable trailing header lane and one body slot.

@export var title := "Section":
	set(value):
		title = value
		_refresh()

@export_multiline var description := "":
	set(value):
		description = value
		_refresh()


func _ready() -> void:
	_refresh()


func get_action_slot() -> Container:
	return get_node(^"Content/Header/ActionSlot") as Container


func get_body_slot() -> Container:
	return get_node(^"Content/BodySlot") as Container


func _refresh() -> void:
	if not is_inside_tree():
		return
	var title_label := get_node_or_null(^"Content/Header/Copy/Title") as Label
	var description_label := get_node_or_null(^"Content/Header/Copy/Description") as Label
	if title_label != null:
		title_label.text = title
		title_label.visible = not title.is_empty()
	if description_label != null:
		description_label.text = description
		description_label.visible = not description.is_empty()
