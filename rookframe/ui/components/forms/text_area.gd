@tool
extends VBoxContainer

## Multiline counterpart to TextField using Godot's native TextEdit.

signal value_changed(value: String)
signal value_committed(value: String)

var _value := ""

@export var label_text := "Field label":
	set(value):
		label_text = value
		_refresh()

@export_multiline var value: String:
	get:
		return _value
	set(next_value):
		_value = next_value
		_refresh()

@export var placeholder := "":
	set(value):
		placeholder = value
		_refresh()

@export_multiline var help_text := "":
	set(value):
		help_text = value
		_refresh()

@export_multiline var error_text := "":
	set(value):
		error_text = value
		_refresh()

@export var editable := true:
	set(value):
		editable = value
		_refresh()


func _ready() -> void:
	var editor := get_node(^"Editor") as TextEdit
	if not editor.text_changed.is_connected(_on_text_changed):
		editor.text_changed.connect(_on_text_changed)
	if not editor.focus_exited.is_connected(_on_focus_exited):
		editor.focus_exited.connect(_on_focus_exited)
	_refresh()


func focus_editor() -> void:
	(get_node(^"Editor") as TextEdit).grab_focus()


func set_error(message: String) -> void:
	error_text = message


func _on_text_changed() -> void:
	_value = (get_node(^"Editor") as TextEdit).text
	value_changed.emit(_value)


func _on_focus_exited() -> void:
	value_committed.emit(_value)


func _refresh() -> void:
	if not is_inside_tree():
		return
	var label := get_node_or_null(^"Label") as Label
	var editor := get_node_or_null(^"Editor") as TextEdit
	var help := get_node_or_null(^"Help") as Label
	var error := get_node_or_null(^"Error") as Label
	if label != null:
		label.text = label_text
	if editor != null:
		if editor.text != _value:
			editor.text = _value
		editor.placeholder_text = placeholder
		editor.editable = editable
		editor.accessibility_name = label_text
		editor.accessibility_description = error_text if not error_text.is_empty() else help_text
	if help != null:
		help.text = help_text
		help.visible = not help_text.is_empty() and error_text.is_empty()
	if error != null:
		error.text = "Error: %s" % error_text
		error.visible = not error_text.is_empty()
