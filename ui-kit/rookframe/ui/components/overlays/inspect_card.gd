extends Control
## Read-only pointer preview and explicit accessible Popover are separate content.
const Focus = preload("res://rookframe/ui/_internal/interaction/focus.gd")
@export var hover_delay_ms := 500:
	set(value):
		if value < 0:
			push_error("InspectCard: hover_delay_ms cannot be negative")
			return
		hover_delay_ms = value
@export var hover_close_delay_ms := 150:
	set(value):
		if value < 0:
			push_error("InspectCard: hover_close_delay_ms cannot be negative")
			return
		hover_close_delay_ms = value
var _anchor: Control
var _inside := false
var _suppressed := false
var _deadline := 0

func _ready() -> void:
	%Inspection.closed.connect(_inspection_closed)
	%Preview.hide()
	set_process(false)

func bind_anchor(control: Control) -> bool:
	if not is_instance_valid(control) or not control.is_inside_tree(): return false
	close()
	_disconnect_anchor()
	_anchor = control
	_anchor.mouse_entered.connect(_entered)
	_anchor.mouse_exited.connect(_exited)
	_anchor.tree_exiting.connect(_anchor_lost)
	return true

func get_preview_slot() -> Container:
	return %PreviewSlot

func get_body_slot() -> Container:
	return %BodySlot

func get_action_slot() -> Container:
	return %ActionSlot

func open_inspection() -> bool:
	%Preview.hide()
	_deadline = 0
	_suppressed = true
	set_process(false)
	return %Inspection.open_for(_anchor)

func close() -> void:
	if not is_node_ready(): return
	_deadline = 0
	_suppressed = true
	set_process(false)
	%Preview.hide()
	%Inspection.close()

func _entered() -> void:
	_inside = true
	_suppressed = false
	_deadline = Time.get_ticks_msec() + hover_delay_ms
	set_process(true)

func _exited() -> void:
	_inside = false
	_deadline = Time.get_ticks_msec() + hover_close_delay_ms
	set_process(true)

func _process(_delta: float) -> void:
	if not is_instance_valid(_anchor) or not _anchor.is_inside_tree() or not _anchor.is_visible_in_tree() or not is_visible_in_tree():
		close()
		return
	if Time.get_ticks_msec() < _deadline: return
	if not _inside or _suppressed or %Inspection.is_open():
		%Preview.hide()
		set_process(false)
		return
	var panel := %Preview as PanelContainer
	panel.show()
	panel.size = panel.get_combined_minimum_size()
	var bounds := get_viewport_rect().grow(-8)
	var location := _anchor.get_global_rect().end + Vector2(0, 8)
	panel.global_position = Vector2(clampf(location.x, bounds.position.x, maxf(bounds.position.x, bounds.end.x - panel.size.x)), clampf(location.y, bounds.position.y, maxf(bounds.position.y, bounds.end.y - panel.size.y)))

func _inspection_closed(_reason: StringName) -> void:
	_suppressed = true
	%Preview.hide()
	set_process(false)

func _anchor_lost() -> void:
	close()
	_disconnect_anchor()

func _disconnect_anchor() -> void:
	if is_instance_valid(_anchor):
		for pair in [[_anchor.mouse_entered, _entered], [_anchor.mouse_exited, _exited], [_anchor.tree_exiting, _anchor_lost]]:
			if pair[0].is_connected(pair[1]): pair[0].disconnect(pair[1])
	_anchor = null

func _exit_tree() -> void:
	_deadline = 0
	_disconnect_anchor()
