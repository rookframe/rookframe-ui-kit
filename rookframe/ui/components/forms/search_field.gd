@tool
extends VBoxContainer

## Search icon, native editor, and clear action inside one focus perimeter.

signal value_changed(value: String)
signal value_committed(value: String)
signal cleared

var _value := ""

@export var label_text := "Search":
	set(value):
		label_text = value
		_refresh()

@export var show_label := true:
	set(value):
		show_label = value
		_refresh()

@export var value: String:
	get:
		return _value
	set(next_value):
		_value = next_value
		_refresh()

@export var placeholder := "Search":
	set(value):
		placeholder = value
		_refresh()


func _ready() -> void:
	var editor := get_node(^"Perimeter/Row/Editor") as LineEdit
	var clear_button := get_node(^"Perimeter/Row/Clear") as Button
	if not editor.text_changed.is_connected(_on_text_changed):
		editor.text_changed.connect(_on_text_changed)
	if not editor.text_submitted.is_connected(_on_text_submitted):
		editor.text_submitted.connect(_on_text_submitted)
	if not editor.focus_entered.is_connected(_on_focus_changed):
		editor.focus_entered.connect(_on_focus_changed)
	if not editor.focus_exited.is_connected(_on_focus_changed):
		editor.focus_exited.connect(_on_focus_changed)
	if not clear_button.focus_entered.is_connected(_on_focus_changed):
		clear_button.focus_entered.connect(_on_focus_changed)
	if not clear_button.focus_exited.is_connected(_on_focus_changed):
		clear_button.focus_exited.connect(_on_focus_changed)
	if not clear_button.pressed.is_connected(_on_clear_pressed):
		clear_button.pressed.connect(_on_clear_pressed)
	_refresh()


func focus_editor() -> void:
	(get_node(^"Perimeter/Row/Editor") as LineEdit).grab_focus()


func clear() -> void:
	if _value.is_empty():
		return
	_value = ""
	_refresh()
	value_changed.emit(_value)
	cleared.emit()
	focus_editor()


func _on_text_changed(next_value: String) -> void:
	_value = next_value
	_refresh()
	value_changed.emit(_value)


func _on_text_submitted(next_value: String) -> void:
	_value = next_value
	value_committed.emit(_value)


func _on_clear_pressed() -> void:
	clear()


func _on_focus_changed() -> void:
	call_deferred(&"_refresh_focus")


func _refresh_focus() -> void:
	if not is_inside_tree():
		return
	var perimeter := get_node(^"Perimeter") as PanelContainer
	var editor := get_node(^"Perimeter/Row/Editor") as LineEdit
	var clear_button := get_node(^"Perimeter/Row/Clear") as Button
	var focused := editor.has_focus() or clear_button.has_focus()
	perimeter.theme_type_variation = &"RookframeSearchFieldFocus" if focused else &"RookframeSearchField"


func _refresh() -> void:
	if not is_inside_tree():
		return
	var label := get_node_or_null(^"Label") as Label
	var editor := get_node_or_null(^"Perimeter/Row/Editor") as LineEdit
	var clear_button := get_node_or_null(^"Perimeter/Row/Clear") as Button
	if label != null:
		label.text = label_text
		label.visible = show_label
	if editor != null:
		if editor.text != _value:
			editor.text = _value
		editor.placeholder_text = placeholder
		editor.accessibility_name = label_text
	if clear_button != null:
		clear_button.visible = not _value.is_empty()
		clear_button.accessibility_name = "Clear %s" % label_text.to_lower()
		clear_button.tooltip_text = clear_button.accessibility_name
	_refresh_focus()
