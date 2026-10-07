@tool
extends PanelContainer

## Compact in-place status with semantic tone, wrapping copy, optional actions,
## and optional dismissal.

signal dismissed

enum Tone {
	INFO,
	PENDING,
	SUCCESS,
	ERROR,
}

const TONE_NAMES := ["Info", "Pending", "Success", "Error"]
const TONE_COLORS := [
	Color("d0be8e"), Color("d0be8e"), Color("a9c4b6"), Color("ff817a"),
]
const ICONS := [
	preload("res://rookframe/ui/icons/info.svg"),
	preload("res://rookframe/ui/icons/spinner.svg"),
	preload("res://rookframe/ui/icons/check.svg"),
	preload("res://rookframe/ui/icons/error.svg"),
]

@export var tone := Tone.INFO:
	set(value):
		tone = clampi(value, Tone.INFO, Tone.ERROR)
		_refresh()

@export var title := "Notice":
	set(value):
		title = value
		_refresh()

@export_multiline var description := "":
	set(value):
		description = value
		_refresh()

@export var dismissible := false:
	set(value):
		dismissible = value
		_refresh()


func _ready() -> void:
	var dismiss_button := get_node(^"Content/Dismiss") as Button
	if not dismiss_button.pressed.is_connected(_on_dismiss_pressed):
		dismiss_button.pressed.connect(_on_dismiss_pressed)
	_refresh()


func get_action_slot() -> Container:
	return get_node(^"Content/Copy/ActionSlot") as Container


func _on_dismiss_pressed() -> void:
	dismissed.emit()


func _refresh() -> void:
	if not is_inside_tree():
		return
	theme_type_variation = &"SilkNotice"
	var icon := get_node_or_null(^"Content/Icon") as TextureRect
	var state_label := get_node_or_null(^"Content/Copy/State") as Label
	var title_label := get_node_or_null(^"Content/Copy/Title") as Label
	var description_label := get_node_or_null(^"Content/Copy/Description") as Label
	var dismiss_button := get_node_or_null(^"Content/Dismiss") as Button
	if icon != null:
		icon.texture = ICONS[tone]
		icon.self_modulate = TONE_COLORS[tone]
		icon.accessibility_name = "%s status" % TONE_NAMES[tone]
	if state_label != null:
		state_label.text = TONE_NAMES[tone]
		state_label.add_theme_color_override("font_color", TONE_COLORS[tone])
	if title_label != null:
		title_label.text = title
	if description_label != null:
		description_label.text = description
		description_label.visible = not description.is_empty()
	if dismiss_button != null:
		dismiss_button.visible = dismissible
	accessibility_name = "%s: %s" % [TONE_NAMES[tone], title]
	accessibility_description = description
