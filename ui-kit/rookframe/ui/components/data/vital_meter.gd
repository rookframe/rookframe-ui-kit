@tool
extends VBoxContainer

## Display-only labelled resource value with a native track.
## The caller chooses the level; the component computes no thresholds.

enum Level { STEADY, WOUNDED, CRITICAL, DEPLETED }

const TRACK_TYPES: Array[StringName] = [
	&"RookframeVital", &"RookframeVitalWounded", &"RookframeVitalCritical", &"RookframeVitalDepleted",
]

@export var caption := "HP":
	set(value):
		caption = value
		_refresh()

@export var value := 0.0:
	set(next):
		value = next
		_refresh()

@export var max_value := 1.0:
	set(next):
		max_value = next
		_refresh()

## Empty shows "<value>/<max_value>".
@export var value_text := "":
	set(next):
		value_text = next
		_refresh()

@export var level := Level.STEADY:
	set(next):
		level = next
		_refresh()

@export var show_track := true:
	set(next):
		show_track = next
		_refresh()


func _ready() -> void:
	_refresh()


func _value_text() -> String:
	return value_text if not value_text.is_empty() else "%s/%s" % [_number(value), _number(max_value)]


func _refresh() -> void:
	if not is_inside_tree():
		return
	var caption_label := get_node_or_null(^"Header/Caption") as Label
	var value_label := get_node_or_null(^"Header/Value") as Label
	var track := get_node_or_null(^"Track") as ProgressBar
	if caption_label != null:
		caption_label.text = caption
		caption_label.visible = not caption.is_empty()
	if value_label != null:
		value_label.text = _value_text()
	if track != null:
		track.max_value = maxf(max_value, 0.0001)
		track.value = value
		track.theme_type_variation = TRACK_TYPES[level]
		track.visible = show_track
	accessibility_name = ("%s %s" % [tr(caption), _value_text()]).strip_edges()


static func _number(amount: float) -> String:
	return str(roundi(amount)) if is_equal_approx(amount, roundf(amount)) else str(amount)


func _enter_tree() -> void:
	preload("res://rookframe/ui/_internal/presentation/binding.gd").attach(self)
