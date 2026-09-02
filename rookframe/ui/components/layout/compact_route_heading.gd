@tool
extends VBoxContainer

## Compact route hierarchy for narrow application workflows. It keeps the
## route label, title, detail, and divider together without owning navigation.

@export var kicker_text := "":
	set(value):
		kicker_text = value
		_refresh()

@export var title_text := "Route title":
	set(value):
		title_text = value
		_refresh()

@export_multiline var detail_text := "":
	set(value):
		detail_text = value
		_refresh()


func _ready() -> void:
	_refresh()


func _refresh() -> void:
	if not is_inside_tree():
		return
	var kicker := get_node_or_null(^"Kicker") as Label
	var title := get_node_or_null(^"Title") as Label
	var detail := get_node_or_null(^"Detail") as Label
	if kicker != null:
		kicker.text = kicker_text
		kicker.visible = not kicker_text.is_empty()
	if title != null:
		title.text = title_text
		title.accessibility_name = title_text
	if detail != null:
		detail.text = detail_text
		detail.visible = not detail_text.is_empty()
