@tool
extends Resource

## Serializable presentation state for one retained Managed Surface task tree.
## Host registries and placement policy remain outside this resource.

signal state_changed(snapshot: Dictionary)

enum Placement {
	DOCKED,
	FLOATING,
}

@export var surface_id := "surface"
@export var task_instance_id := "task"
@export var placement := Placement.DOCKED
@export var closed := false
@export var minimized := false
@export var focused := false
@export_range(240.0, 1600.0, 4.0, "suffix:px") var dock_width := 560.0
@export var floating_rect := Rect2(80, 80, 720, 720)
@export_range(0.0, 100000.0, 1.0, "suffix:px") var scroll_offset := 0.0


func is_visible() -> bool:
	return not closed and not minimized


func placement_name() -> StringName:
	return &"floating" if placement == Placement.FLOATING else &"docked"


func open_surface() -> void:
	closed = false
	minimized = false
	focused = true
	_mark_changed()


func close_surface() -> void:
	closed = true
	minimized = false
	focused = false
	_mark_changed()


func minimize_surface() -> bool:
	if closed:
		return false
	minimized = true
	focused = false
	_mark_changed()
	return true


func restore_surface() -> bool:
	if closed:
		return false
	minimized = false
	focused = true
	_mark_changed()
	return true


func focus_surface() -> bool:
	if not is_visible():
		return false
	if focused:
		return true
	focused = true
	_mark_changed()
	return true


func set_placement(next_placement: int) -> void:
	var normalized := clampi(next_placement, Placement.DOCKED, Placement.FLOATING)
	if placement == normalized:
		return
	placement = normalized
	focused = true
	_mark_changed()


func set_dock_width(value: float) -> void:
	var normalized := maxf(240.0, value)
	if is_equal_approx(dock_width, normalized):
		return
	dock_width = normalized
	_mark_changed()


func set_floating_rect(value: Rect2) -> void:
	if floating_rect == value:
		return
	floating_rect = value
	_mark_changed()


func set_scroll_offset(value: float) -> void:
	var normalized := maxf(0.0, value)
	if is_equal_approx(scroll_offset, normalized):
		return
	scroll_offset = normalized
	_mark_changed()


func state_snapshot() -> Dictionary:
	return {
		"surface_id": surface_id,
		"task_instance_id": task_instance_id,
		"placement": placement_name(),
		"closed": closed,
		"minimized": minimized,
		"focused": focused,
		"dock_width": dock_width,
		"floating_rect": floating_rect,
		"scroll_offset": scroll_offset,
	}


func restore_snapshot(snapshot: Dictionary) -> void:
	surface_id = str(snapshot.get("surface_id", surface_id))
	task_instance_id = str(snapshot.get("task_instance_id", task_instance_id))
	placement = Placement.FLOATING if snapshot.get("placement", placement_name()) == "floating" else Placement.DOCKED
	closed = bool(snapshot.get("closed", closed))
	minimized = bool(snapshot.get("minimized", minimized)) and not closed
	focused = bool(snapshot.get("focused", focused)) and is_visible()
	dock_width = maxf(240.0, float(snapshot.get("dock_width", dock_width)))
	var restored_rect: Variant = snapshot.get("floating_rect", floating_rect)
	if restored_rect is Rect2:
		floating_rect = restored_rect
	scroll_offset = maxf(0.0, float(snapshot.get("scroll_offset", scroll_offset)))
	_mark_changed()


func _mark_changed() -> void:
	emit_changed()
	state_changed.emit(state_snapshot())
