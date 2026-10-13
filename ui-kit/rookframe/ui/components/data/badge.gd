@tool
extends PanelContainer

## Compact semantic classification chip with optional pictogram.

@export var label_text := "Badge":
	set(value):
		label_text = value
		_refresh()

@export var icon: Texture2D:
	set(value):
		icon = value
		_refresh()


func _ready() -> void:
	_refresh()


func _refresh() -> void:
	if not is_inside_tree():
		return
	var icon_rect := get_node_or_null(^"Content/Icon") as TextureRect
	var label := get_node_or_null(^"Content/Label") as Label
	if icon_rect != null:
		icon_rect.texture = icon
		icon_rect.visible = icon != null
	if label != null:
		label.text = label_text
	accessibility_name = label_text
