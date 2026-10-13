@tool
extends Button

## Detailed or compact single-select row whose complete area is one native
## toggle button. Assign a ButtonGroup to compose radio sets.

signal selection_changed(selected: bool)

enum Variant {
	DETAILED,
	COMPACT,
}

@export var title := "Choice":
	set(value):
		title = value
		_refresh()

@export_multiline var description := "Supporting decision copy":
	set(value):
		description = value
		_refresh()

@export var action_label := "Select":
	set(value):
		action_label = value
		_refresh()

@export var variant := Variant.DETAILED:
	set(value):
		variant = value
		_refresh()


func _ready() -> void:
	if not toggled.is_connected(_on_toggled):
		toggled.connect(_on_toggled)
	_refresh()


func set_selected(selected: bool) -> void:
	button_pressed = selected
	_refresh()


func is_selected() -> bool:
	return button_pressed


func _on_toggled(selected: bool) -> void:
	_refresh()
	selection_changed.emit(selected)


func _refresh() -> void:
	if not is_inside_tree():
		return
	var title_label := get_node_or_null(^"Content/Copy/Title") as Label
	var description_label := get_node_or_null(^"Content/Copy/Description") as Label
	var state_label := get_node_or_null(^"Content/State") as Label
	if title_label != null:
		title_label.text = title
	if description_label != null:
		description_label.text = description
		description_label.visible = variant == Variant.DETAILED and not description.is_empty()
	if state_label != null:
		state_label.text = "Selected" if button_pressed else action_label
		state_label.theme_type_variation = &"RookframeSuccess" if button_pressed else &"RookframeStatus"
	accessibility_name = title
	accessibility_description = ("Selected. " if button_pressed else "Not selected. ") + description
