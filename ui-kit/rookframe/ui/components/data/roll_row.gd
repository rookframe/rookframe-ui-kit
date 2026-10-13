@tool
extends GridContainer

## Six-slot roll/result row: state, ordinal, die, identity, result, action.

signal layout_profile_changed(profile: StringName)

enum State {
	COMPLETE,
	CURRENT,
	PENDING,
	LOCKED,
}

const STATE_NAMES := ["Complete", "Current", "Pending", "Locked"]
const STATE_VARIATIONS := [
	&"RookframeSuccess",
	&"RookframePending",
	&"RookframeMeta",
	&"RookframeMeta",
]
const STATE_ICONS := [
	preload("res://rookframe/ui/icons/check.svg"),
	preload("res://rookframe/ui/icons/forward.svg"),
	preload("res://rookframe/ui/icons/spinner.svg"),
	preload("res://rookframe/ui/icons/lock.svg"),
]

@export var state := State.PENDING:
	set(value):
		state = clampi(value, State.COMPLETE, State.LOCKED)
		_refresh()

@export var ordinal := "1":
	set(value):
		ordinal = value
		_refresh()

@export var title := "Roll":
	set(value):
		title = value
		_refresh()

@export_multiline var detail := "":
	set(value):
		detail = value
		_refresh()

@export var result := "":
	set(value):
		result = value
		_refresh()

@export var die_icon: Texture2D = preload("res://rookframe/ui/icons/dice.svg"):
	set(value):
		die_icon = value
		_refresh()

@export_range(480.0, 1200.0, 4.0, "suffix:px") var compact_width := 720.0:
	set(value):
		compact_width = maxf(480.0, value)
		_refresh()

var _profile: StringName = &"wide"


func _notification(what: int) -> void:
	if what == NOTIFICATION_READY or what == NOTIFICATION_RESIZED:
		_refresh()


func get_action_slot() -> Container:
	return get_node(^"ActionSlot") as Container


func _refresh() -> void:
	if not is_inside_tree():
		return
	var compact := size.x > 0.0 and size.x < compact_width
	columns = 2 if compact else 6
	var marker := get_node_or_null(^"State") as HBoxContainer
	var marker_icon := get_node_or_null(^"State/Icon") as TextureRect
	var marker_text := get_node_or_null(^"State/Text") as Label
	var ordinal_label := get_node_or_null(^"Ordinal") as Label
	var die := get_node_or_null(^"Die") as TextureRect
	var title_label := get_node_or_null(^"Identity/Title") as Label
	var detail_label := get_node_or_null(^"Identity/Detail") as Label
	var result_label := get_node_or_null(^"Result") as Label
	if marker != null:
		marker.accessibility_name = STATE_NAMES[state]
	if marker_icon != null:
		marker_icon.texture = STATE_ICONS[state]
	if marker_text != null:
		marker_text.text = STATE_NAMES[state]
		marker_text.theme_type_variation = STATE_VARIATIONS[state]
	if ordinal_label != null:
		ordinal_label.text = ordinal
	if die != null:
		die.texture = die_icon
	if title_label != null:
		title_label.text = title
	if detail_label != null:
		detail_label.text = detail
		detail_label.visible = not detail.is_empty()
	if result_label != null:
		result_label.text = result
		result_label.accessibility_name = "No result yet" if result.is_empty() else "Result %s" % result
	accessibility_name = "%s, %s" % [title, STATE_NAMES[state]]
	accessibility_description = detail
	var next_profile: StringName = &"compact" if compact else &"wide"
	if _profile == next_profile:
		return
	_profile = next_profile
	layout_profile_changed.emit(_profile)
