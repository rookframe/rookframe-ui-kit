@tool
extends BoxContainer

## Two-region layout that changes from a weighted row to one reading-order
## column based on its own width.

signal layout_profile_changed(profile: StringName)

@export_range(320.0, 1200.0, 4.0, "suffix:px") var compact_width := 720.0:
	set(value):
		compact_width = maxf(320.0, value)
		_apply_profile()

@export_range(0.2, 0.8, 0.05) var primary_ratio := 0.4:
	set(value):
		primary_ratio = clampf(value, 0.2, 0.8)
		_apply_profile()

@export var compact_secondary_first := false:
	set(value):
		compact_secondary_first = value
		_apply_profile()

var _profile: StringName = &"wide"


func _notification(what: int) -> void:
	if what == NOTIFICATION_READY or what == NOTIFICATION_RESIZED:
		_apply_profile()


func get_primary_slot() -> Container:
	return get_node(^"PrimarySlot") as Container


func get_secondary_slot() -> Container:
	return get_node(^"SecondarySlot") as Container


func _apply_profile() -> void:
	if not is_inside_tree():
		return
	var primary := get_node_or_null(^"PrimarySlot") as Control
	var secondary := get_node_or_null(^"SecondarySlot") as Control
	if primary == null or secondary == null:
		return
	var compact := size.x > 0.0 and size.x < compact_width
	vertical = compact
	if compact:
		primary.size_flags_stretch_ratio = 1.0
		secondary.size_flags_stretch_ratio = 1.0
		move_child(secondary if compact_secondary_first else primary, 0)
	else:
		primary.size_flags_stretch_ratio = primary_ratio
		secondary.size_flags_stretch_ratio = 1.0 - primary_ratio
		move_child(primary, 0)
	var next_profile: StringName = &"compact" if compact else &"wide"
	if _profile == next_profile:
		return
	_profile = next_profile
	layout_profile_changed.emit(_profile)
