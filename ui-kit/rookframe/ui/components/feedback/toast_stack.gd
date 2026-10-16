extends VBoxContainer
## Bounded arrival queue. Removing a message precedes its single terminal event.
signal finished(id: String, reason: StringName, action_id: String)
const NOTICE = preload("res://rookframe/ui/components/feedback/notice.tscn")
const Focus = preload("res://rookframe/ui/_internal/interaction/focus.gd")
@export var timers_paused := false
var _visible_limit := 3
var _waiting_limit := 20
var _messages: Array[Dictionary] = []
var _cards: Dictionary = {}
var _elapsed: Dictionary = {}
var _tick := 0
var _application_focused := true

func _ready() -> void:
	_tick = _clock_ms()
	set_process(true)
	_sync()

func configure_limits(visible_count: int, waiting: int) -> bool:
	if visible_count < 1 or waiting < 0: return false
	if visible_count < _cards.size() or waiting < maxi(0, _messages.size() - _visible_limit): return false
	_visible_limit = visible_count
	_waiting_limit = waiting
	_sync()
	return true

func push(message: Dictionary) -> bool:
	var normalized := _normalize(message)
	if normalized.is_empty() or _index(normalized.id) >= 0: return false
	if _messages.size() >= _visible_limit + _waiting_limit: return false
	_messages.append(normalized)
	_sync()
	return true

func update_message(id: String, changes: Dictionary) -> bool:
	var index := _index(id)
	if index < 0 or (changes.has("id") and changes.id != id): return false
	var next := _messages[index].duplicate(true)
	next.merge(changes, true)
	next = _normalize(next)
	if next.is_empty(): return false
	_messages[index] = next
	_sync()
	return true

func dismiss(id: String) -> bool:
	return _finish(id, &"host")

func clear() -> void:
	var ids: Array[String] = []
	for message in _messages: ids.append(message.id)
	_messages.clear()
	_elapsed.clear()
	_release_cards()
	# Remove the complete batch before callbacks can enqueue a new operation.
	for id in ids: finished.emit(id, &"clear", "")

func _release_cards() -> void:
	for card in _cards.values():
		remove_child(card)
		card.queue_free()
	_cards.clear()

func _normalize(message: Dictionary) -> Dictionary:
	if not message.get("id") is String or message.id.is_empty(): return {}
	if not message.get("title") is String or message.title.is_empty(): return {}
	for key in ["description", "action_id", "action_label"]:
		if not message.get(key, "") is String: return {}
	for key in ["action_disabled", "dismissible"]:
		if not message.get(key, false) is bool: return {}
	if not (message.get("tone", &"info") is StringName or message.get("tone", &"info") is String): return {}
	if message.get("tone", &"info") not in [&"info", &"success", &"error"]: return {}
	if message.get("action_id", "").is_empty() != message.get("action_label", "").is_empty(): return {}
	var duration = message.get("duration_ms", 5000 if message.get("action_id", "").is_empty() else 0)
	if not duration is int or duration < 0: return {}
	return {"id": message.id, "title": message.title, "description": message.get("description", ""), "tone": StringName(message.get("tone", &"info")), "duration_ms": duration, "action_id": message.get("action_id", ""), "action_label": message.get("action_label", ""), "action_disabled": message.get("action_disabled", false), "dismissible": message.get("dismissible", true)}

func _index(id: String) -> int:
	for index in _messages.size():
		if _messages[index].id == id: return index
	return -1

func _sync() -> void:
	if not is_node_ready(): return
	for index in mini(_visible_limit, _messages.size()):
		var message := _messages[index]
		var id: String = message.id
		var created := not _cards.has(id)
		if created:
			var card = NOTICE.instantiate()
			card.dismissed.connect(func(): _finish(id, &"user"))
			_cards[id] = card
			_elapsed[id] = 0
			add_child(card)
			var action := Button.new()
			action.name = "ToastAction"
			action.custom_minimum_size = Vector2(44, 44)
			action.pressed.connect(_action.bind(id))
			card.get_action_slot().add_child(action)
		var card = _cards[id]
		move_child(card, index)
		if not created: card.accessibility_live = AccessibilityServer.LIVE_OFF
		card.title = message.title
		card.description = message.description
		card.tone = {&"info": 0, &"success": 2, &"error": 3}[message.tone]
		card.dismissible = message.dismissible
		var action: Button = card.get_action_slot().get_node("ToastAction")
		action.text = message.action_label
		action.accessibility_name = message.action_label
		action.visible = not message.action_id.is_empty()
		action.disabled = message.action_disabled
		action.focus_mode = Control.FOCUS_NONE if action.disabled else Control.FOCUS_ALL
		# Native live regions announce additions, never queued records.
		if created: card.accessibility_live = AccessibilityServer.LIVE_POLITE

func _action(id: String) -> void:
	var index := _index(id)
	if index < 0: return
	var message := _messages[index]
	if message.action_disabled or message.action_id.is_empty(): return
	_finish(id, &"action", message.action_id)

func _finish(id: String, reason: StringName, action_id := "") -> bool:
	var index := _index(id)
	if index < 0: return false
	var restore_focus := false
	if _cards.has(id):
		var focused := get_viewport().gui_get_focus_owner()
		restore_focus = focused != null and (_cards[id] == focused or _cards[id].is_ancestor_of(focused))
	_messages.remove_at(index)
	_elapsed.erase(id)
	if _cards.has(id):
		var card: Control = _cards[id]
		_cards.erase(id)
		remove_child(card)
		card.queue_free()
	_sync()
	if restore_focus: Focus.restore(get_children(), index)
	finished.emit(id, reason, action_id)
	return true

func _process(_delta: float) -> void:
	var now := _clock_ms()
	var elapsed := now - _tick
	_tick = now
	if timers_paused or not is_visible_in_tree() or not _application_focused: return
	var focus := get_viewport().gui_get_focus_owner()
	var expired: Array[String] = []
	for id in _cards:
		var card: Control = _cards[id]
		if card.get_global_rect().has_point(card.get_global_mouse_position()): continue
		if focus != null and (focus == card or card.is_ancestor_of(focus)): continue
		var message := _messages[_index(id)]
		_elapsed[id] += elapsed
		if message.duration_ms > 0 and _elapsed[id] >= message.duration_ms: expired.append(id)
	for id in expired: _finish(id, &"timeout")

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT: _application_focused = false
	elif what == NOTIFICATION_APPLICATION_FOCUS_IN:
		_application_focused = true
		_tick = _clock_ms()
	elif what == NOTIFICATION_PAUSED or what == NOTIFICATION_UNPAUSED:
		_tick = _clock_ms()

func _exit_tree() -> void:
	set_process(false)
	_messages.clear()
	_elapsed.clear()
	_release_cards()

func _clock_ms() -> int:
	return Time.get_ticks_msec()
