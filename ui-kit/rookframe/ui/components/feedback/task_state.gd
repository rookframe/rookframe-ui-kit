@tool
extends PanelContainer
const Appearance = preload("res://rookframe/ui/_internal/presentation/appearance.gd")

## Whole-task loading, empty, recovery, success, or terminal state region.

enum State {
	LOADING,
	EMPTY,
	SUCCESS,
	ERROR,
}

const STATE_NAMES := ["Loading", "Empty", "Success", "Error"]
const PANEL_VARIATIONS := [
	&"RookframeInlineNoticePending",
	&"RookframeInlineNoticeInfo",
	&"RookframeInlineNoticeSuccess",
	&"RookframeInlineNoticeError",
]
const TEXT_VARIATIONS := [
	&"RookframePending",
	&"RookframeStatus",
	&"RookframeSuccess",
	&"RookframeError",
]
const ICONS := [
	preload("res://rookframe/ui/icons/spinner.svg"),
	preload("res://rookframe/ui/icons/list.svg"),
	preload("res://rookframe/ui/icons/check.svg"),
	preload("res://rookframe/ui/icons/error.svg"),
]
const SPINNER_SPEED := TAU * 0.8

@export var reduced_motion := false:
	set(value):
		reduced_motion = value
		_refresh()

@export var state := State.EMPTY:
	set(value):
		state = clampi(value, State.LOADING, State.ERROR)
		_refresh()

@export var title := "Nothing here yet":
	set(value):
		title = value
		_refresh()

@export_multiline var description := "":
	set(value):
		description = value
		_refresh()


func _ready() -> void:
	_refresh()


func _process(delta: float) -> void:
	var icon := get_node_or_null(^"Content/Icon") as TextureRect
	if icon == null:
		return
	icon.pivot_offset = icon.size * 0.5
	icon.rotation = fmod(icon.rotation + SPINNER_SPEED * delta, TAU)


func get_action_slot() -> Container:
	return get_node(^"Content/ActionSlot") as Container


func _refresh() -> void:
	if not is_inside_tree():
		return
	theme_type_variation = PANEL_VARIATIONS[state]
	var icon := get_node_or_null(^"Content/Icon") as TextureRect
	var state_label := get_node_or_null(^"Content/State") as Label
	var title_label := get_node_or_null(^"Content/Title") as Label
	var description_label := get_node_or_null(^"Content/Description") as Label
	if icon != null:
		icon.texture = ICONS[state]
		icon.self_modulate = get_theme_color(&"font_color", TEXT_VARIATIONS[state]) if state in [State.SUCCESS, State.ERROR] else _state_icon_color()
		icon.accessibility_name = "%s state" % STATE_NAMES[state]
		if state != State.LOADING or reduced_motion:
			icon.rotation = 0.0
	if state_label != null:
		state_label.text = STATE_NAMES[state]
		state_label.theme_type_variation = TEXT_VARIATIONS[state]
	if title_label != null:
		title_label.text = title
	if description_label != null:
		description_label.text = description
		description_label.visible = not description.is_empty()
	set_process(state == State.LOADING and not reduced_motion)
	accessibility_name = "%s: %s" % [STATE_NAMES[state], title]
	accessibility_description = description

func _state_icon_color() -> Color:
	if Appearance.has_hook(self, &"_state_icon_color"):
		return Appearance.invoke(self, &"_state_icon_color", [])
	return get_theme_color("font_color", "Label")


func _enter_tree() -> void:
	preload("res://rookframe/ui/_internal/presentation/binding.gd").attach(self)

func _presentation_changed() -> void:
	_refresh()
