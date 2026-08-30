@tool
extends PanelContainer

## Whole-task loading, empty, recovery, success, or terminal state region.

enum State {
	LOADING,
	EMPTY,
	SUCCESS,
	ERROR,
}

const STATE_NAMES := ["Loading", "Empty", "Success", "Error"]
const PANEL_VARIATIONS := [
	&"RookframeNoticePending",
	&"RookframeNoticeInfo",
	&"RookframeNoticeSuccess",
	&"RookframeNoticeError",
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
	var progress := get_node_or_null(^"Content/Progress") as ProgressBar
	if icon != null:
		icon.texture = ICONS[state]
		icon.accessibility_name = "%s state" % STATE_NAMES[state]
	if state_label != null:
		state_label.text = STATE_NAMES[state].to_upper()
		state_label.theme_type_variation = TEXT_VARIATIONS[state]
	if title_label != null:
		title_label.text = title
	if description_label != null:
		description_label.text = description
		description_label.visible = not description.is_empty()
	if progress != null:
		progress.visible = state == State.LOADING
		progress.indeterminate = state == State.LOADING
	accessibility_name = "%s: %s" % [STATE_NAMES[state], title]
	accessibility_description = description
