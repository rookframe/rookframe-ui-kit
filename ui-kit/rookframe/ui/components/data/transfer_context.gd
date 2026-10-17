class_name RookframeTransferContext
extends Node
## One host-owned transfer region. Requests never mutate inventory data.
signal state_changed(state: StringName)
signal transfer_requested(request_id: int, source_id: String, target_id: String, payload: Dictionary)
const Payload = preload("res://rookframe/ui/_internal/interaction/payload.gd")
const Focus = preload("res://rookframe/ui/_internal/interaction/focus.gd")
@export var focus_fallback: Control
var placement_validator: Callable
var _slots: Dictionary = {}
var _state: StringName = &"idle"
var _source := ""
var _target := ""
var _payload: Dictionary = {}
var _serial := 0
var _pending_id := 0
var _region: Control
var _feedback: Label

func _enter_tree() -> void:
	var parent := get_parent()
	while parent != null and not parent is Control: parent = parent.get_parent()
	_region = parent as Control

func _can_register(slot: Button) -> bool:
	return is_instance_valid(_region) and _region.is_ancestor_of(slot) and slot.get_viewport() == _region.get_viewport() and not slot.slot_id.is_empty() and (not _slots.has(slot.slot_id) or _slots[slot.slot_id] == slot)

func _register(slot: Button) -> bool:
	if not _can_register(slot):
		push_error("TransferContext: invalid region or duplicate slot ID")
		return false
	_slots[slot.slot_id] = slot
	return true

func _unregister(slot: Button) -> void:
	if _slots.get(slot.slot_id) != slot: return
	_slots.erase(slot.slot_id)
	if _source == slot.slot_id and _state == &"carrying": cancel_transfer(&"source_lost")

func get_state() -> StringName:
	return _state

func begin_transfer(source_id: String) -> bool:
	if _state != &"idle" or not _available(source_id, true): return false
	var source: Button = _slots[source_id]
	if not Payload.valid(source.payload): return false
	_source = source_id
	_payload = source.payload.duplicate(true)
	_set_state(&"carrying")
	_show_feedback(tr("Carrying %s") % source.accessibility_name)
	return true

func evaluate_target(target_id: String) -> Dictionary:
	if _state != &"carrying" or target_id == _source or not _available(target_id, false) or not _available(_source, true): return _unavailable()
	if not placement_validator.is_valid(): return _unavailable()
	var result = placement_validator.call(_source, target_id, _payload.duplicate(true))
	if not result is Dictionary or not result.get("allowed") is bool or not result.get("reason") is String:
		push_error("TransferContext: validator must return allowed: bool and reason: String")
		return _unavailable()
	if not result.allowed and result.reason.is_empty():
		push_error("TransferContext: unavailable target requires a reason")
		return _unavailable()
	return {"allowed": result.allowed, "reason": result.reason}

func request_placement(target_id: String) -> int:
	var result := evaluate_target(target_id)
	if not result.allowed:
		if _state == &"carrying": _show_feedback(result.reason)
		return 0
	_serial += 1
	var issued := _serial
	_pending_id = issued
	_target = target_id
	_set_state(&"pending")
	_show_feedback(tr("Transfer pending"))
	transfer_requested.emit(issued, _source, _target, _payload.duplicate(true))
	# A host may resolve synchronously inside the signal.
	return issued

func resolve_transfer(request_id: int, accepted: bool, error_text := "") -> bool:
	if _state != &"pending" or request_id != _pending_id: return false
	_pending_id = 0
	if accepted:
		var target: Control = _slots.get(_target)
		_end()
		if not Focus.give(target): Focus.give(focus_fallback)
	elif _available(_source, true):
		_set_state(&"carrying")
		_show_feedback(error_text if not error_text.is_empty() else tr("Transfer unavailable"))
	else:
		_end()
		Focus.give(focus_fallback)
	return true

func cancel_transfer(reason: StringName = &"cancel") -> bool:
	if reason not in [&"cancel", &"host", &"source_lost", &"context_hidden", &"invalid_drop"]:
		push_error("TransferContext: invalid cancellation reason")
		return false
	if _state != &"carrying": return false
	var source: Control = _slots.get(_source)
	_end()
	if not Focus.give(source): Focus.give(focus_fallback)
	return true

func _available(id: String, source: bool) -> bool:
	var slot: Button = _slots.get(id)
	return is_instance_valid(_region) and _region.is_visible_in_tree() and is_instance_valid(slot) and slot.is_visible_in_tree() and not slot.disabled and (slot.can_source if source else slot.can_target)

func _unavailable() -> Dictionary:
	return {"allowed": false, "reason": tr("Transfer unavailable")}

func _set_state(next: StringName) -> void:
	if _state == next: return
	_state = next
	state_changed.emit(_state)

func _end() -> void:
	_source = ""
	_target = ""
	_payload.clear()
	_pending_id = 0
	_remove_feedback()
	_set_state(&"idle")

func _process(_delta: float) -> void:
	if _state == &"carrying" and not _available(_source, true): cancel_transfer(&"source_lost")

func _unhandled_input(event: InputEvent) -> void:
	if _state != &"idle" and event.is_action_pressed(&"ui_cancel"):
		get_viewport().set_input_as_handled()
		if _state == &"carrying": cancel_transfer()

func _show_feedback(copy: String) -> void:
	if not is_instance_valid(_region): return
	if not is_instance_valid(_feedback):
		_feedback = Label.new()
		_feedback.set_as_top_level(not _region is Container)
		_feedback.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_feedback.custom_minimum_size = Vector2(160, 44)
		_feedback.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_feedback.theme_type_variation = &"RookframeStatus"
		_feedback.accessibility_live = AccessibilityServer.LIVE_POLITE
		_region.add_child(_feedback)
	_feedback.text = copy
	_feedback.accessibility_name = copy
	if not _region is Container: _feedback.global_position = _region.global_position

func _target_feedback(id: String) -> void:
	if _state != &"carrying": return
	var result := evaluate_target(id)
	_show_feedback(tr("Place item") if result.allowed else result.reason)

func _remove_feedback() -> void:
	if is_instance_valid(_feedback):
		_feedback.get_parent().remove_child(_feedback)
		_feedback.queue_free()
	_feedback = null

func _exit_tree() -> void:
	_remove_feedback()
	_slots.clear()
	_payload.clear()
	_state = &"idle"
	_pending_id = 0
