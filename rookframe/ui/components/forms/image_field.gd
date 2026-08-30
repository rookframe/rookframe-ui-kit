@tool
extends VBoxContainer

## Neutral image-replacement field. The consumer owns file admission and calls
## set_preview() only after a replacement is ready.

signal replace_requested

@export var title := "Image":
	set(value):
		title = value
		_refresh()

@export_multiline var help_text := "":
	set(value):
		help_text = value
		_refresh()

@export_multiline var error_text := "":
	set(value):
		error_text = value
		_refresh()

@export var preview: Texture2D:
	set(value):
		preview = value
		_refresh()

@export var change_label := "Replace image":
	set(value):
		change_label = value
		_refresh()

@export var disabled := false:
	set(value):
		disabled = value
		_refresh()


func _ready() -> void:
	var replace_button := get_node(^"PreviewRow/Replace") as Button
	if not replace_button.pressed.is_connected(_on_replace_pressed):
		replace_button.pressed.connect(_on_replace_pressed)
	_refresh()


func set_preview(texture: Texture2D) -> void:
	preview = texture
	error_text = ""


func set_error(message: String) -> void:
	error_text = message


func _on_replace_pressed() -> void:
	replace_requested.emit()


func _refresh() -> void:
	if not is_inside_tree():
		return
	var title_label := get_node_or_null(^"Title") as Label
	var help := get_node_or_null(^"Help") as Label
	var image := get_node_or_null(^"PreviewRow/Frame/Image") as TextureRect
	var replace_button := get_node_or_null(^"PreviewRow/Replace") as Button
	var error := get_node_or_null(^"Error") as Label
	if title_label != null:
		title_label.text = title
	if help != null:
		help.text = help_text
		help.visible = not help_text.is_empty()
	if image != null:
		image.texture = preview
		image.accessibility_name = "%s preview" % title
	if replace_button != null:
		replace_button.text = change_label
		replace_button.disabled = disabled
		replace_button.accessibility_name = change_label
	if error != null:
		error.text = "Error: %s" % error_text
		error.visible = not error_text.is_empty()
