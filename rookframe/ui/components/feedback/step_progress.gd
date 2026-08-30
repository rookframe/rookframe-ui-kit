@tool
extends VBoxContainer

## Responsive two-to-eight-step workflow progress. A full labelled rail is
## shown at wide widths and a compact current/total label plus native progress
## bar is shown below the component threshold.

signal layout_profile_changed(profile: StringName)

@export var accessible_label := "Workflow progress":
	set(value):
		accessible_label = value
		_refresh()

@export var steps := PackedStringArray(["First step", "Second step"]):
	set(value):
		steps = value
		_refresh()

@export_range(1, 8, 1) var current_step := 1:
	set(value):
		current_step = clampi(value, 1, 8)
		_refresh()

@export_range(480.0, 1200.0, 4.0, "suffix:px") var compact_width := 720.0:
	set(value):
		compact_width = maxf(480.0, value)
		_refresh()

var _profile: StringName = &"wide"


func _notification(what: int) -> void:
	if what == NOTIFICATION_READY or what == NOTIFICATION_RESIZED:
		_refresh()


func _refresh() -> void:
	if not is_inside_tree():
		return
	var normalized_steps := steps.slice(0, mini(steps.size(), 8))
	if normalized_steps.size() < 2:
		normalized_steps = PackedStringArray(["First step", "Second step"])
	var normalized_current := clampi(current_step, 1, normalized_steps.size())
	var full := get_node_or_null(^"Full") as HBoxContainer
	var compact := get_node_or_null(^"Compact") as VBoxContainer
	var use_compact := size.x > 0.0 and size.x < compact_width
	if full != null:
		full.visible = not use_compact
		for index in range(8):
			var item := full.get_child(index) as Label
			item.visible = index < normalized_steps.size()
			if index >= normalized_steps.size():
				continue
			var position := index + 1
			var state_name := "complete" if position < normalized_current else ("current" if position == normalized_current else "pending")
			item.text = "%d. %s - %s" % [position, normalized_steps[index], state_name]
			item.theme_type_variation = &"RookframeSuccess" if position < normalized_current else (&"RookframePending" if position == normalized_current else &"RookframeMeta")
	if compact != null:
		compact.visible = use_compact
		var copy := compact.get_node(^"Copy") as Label
		var progress := compact.get_node(^"Progress") as ProgressBar
		copy.text = "Step %d of %d: %s" % [normalized_current, normalized_steps.size(), normalized_steps[normalized_current - 1]]
		progress.max_value = normalized_steps.size()
		progress.value = normalized_current
		progress.accessibility_name = accessible_label
		progress.accessibility_description = copy.text
	accessibility_name = accessible_label
	var next_profile: StringName = &"compact" if use_compact else &"wide"
	if _profile == next_profile:
		return
	_profile = next_profile
	layout_profile_changed.emit(_profile)
