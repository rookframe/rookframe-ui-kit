@tool
extends BoxContainer

## Leading/trailing action lanes that stack without changing source-order focus.

signal layout_profile_changed(profile: StringName)

@export_range(320.0, 960.0, 4.0, "suffix:px") var compact_width := 560.0:
	set(value):
		compact_width = maxf(320.0, value)
		_apply_profile()

var _profile: StringName = &"wide"


func _notification(what: int) -> void:
	if what == NOTIFICATION_READY or what == NOTIFICATION_RESIZED:
		_apply_profile()


func get_leading_slot() -> Container:
	return get_node(^"LeadingSlot") as Container


func get_trailing_slot() -> Container:
	return get_node(^"TrailingSlot") as Container


func _apply_profile() -> void:
	if not is_inside_tree():
		return
	var compact := size.x > 0.0 and size.x < compact_width
	vertical = compact
	var leading := get_node_or_null(^"LeadingSlot") as Control
	var trailing := get_node_or_null(^"TrailingSlot") as Control
	if leading != null:
		leading.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if trailing != null:
		trailing.size_flags_horizontal = Control.SIZE_EXPAND_FILL if compact else Control.SIZE_SHRINK_END
	var next_profile: StringName = &"compact" if compact else &"wide"
	if _profile == next_profile:
		return
	_profile = next_profile
	layout_profile_changed.emit(_profile)
