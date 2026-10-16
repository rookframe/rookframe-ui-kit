extends PopupPanel
## Anchored native popup capture with retained, bounded content.
signal closed(reason: StringName)
const Focus = preload("res://rookframe/ui/_internal/interaction/focus.gd")
@export var focus_fallback: Control
var _anchor: Control
var _open := false
var _owner_window: Window
var _reason: StringName = &"outside"

func _ready() -> void:
	popup_hide.connect(_hidden)
	close_requested.connect(func(): close(&"outside"))
	set_process(false)

func get_content_slot() -> Container:
	return %ContentSlot

func is_open() -> bool:
	return _open

func open_for(anchor: Control, initial_focus: Control = null) -> bool:
	if not is_inside_tree() or not is_instance_valid(anchor) or not anchor.is_inside_tree() or not anchor.is_visible_in_tree(): return false
	if initial_focus != null:
		if not is_instance_valid(initial_focus) or not get_content_slot().is_ancestor_of(initial_focus): return false
		if initial_focus.focus_mode == Control.FOCUS_NONE or (initial_focus is BaseButton and initial_focus.disabled): return false
		var parent: Node = initial_focus
		while parent != self:
			if parent is Control and not parent.visible: return false
			parent = parent.get_parent()
	if _open:
		if _anchor == anchor: return true
		close(&"replace")
	_anchor = anchor
	_owner_window = anchor.get_window()
	_open = true
	_reason = &"outside"
	_place()
	popup(Rect2i(position, size))
	set_process(true)
	var target := initial_focus if initial_focus != null else Focus.first(get_content_slot())
	Focus.give(target)
	return true

func close(reason: StringName = &"host") -> void:
	if reason not in [&"host", &"cancel", &"outside", &"anchor_lost", &"owner_hidden", &"replace"]:
		push_error("Popover: invalid close reason")
		return
	if not _open: return
	_reason = reason
	hide()
	if _open: _hidden()

func _hidden() -> void:
	if not _open: return
	_open = false
	set_process(false)
	var anchor := _anchor
	_anchor = null
	_owner_window = null
	if not Focus.give(anchor): Focus.give(focus_fallback)
	closed.emit(_reason)

func _input(event: InputEvent) -> void:
	if _open and event.is_action_pressed(&"ui_cancel"):
		set_input_as_handled()
		close(&"cancel")

func _process(_delta: float) -> void:
	if not is_instance_valid(_owner_window) or not _owner_window.visible:
		close(&"owner_hidden")
	elif not is_instance_valid(_anchor) or not _anchor.is_inside_tree() or not _anchor.is_visible_in_tree():
		close(&"anchor_lost")
	else:
		var owner := get_parent()
		if owner is CanvasItem and not owner.is_visible_in_tree(): close(&"owner_hidden")
		else: _place()

func _place() -> void:
	var margin := get_theme_constant("bounds_margin", "RookframePopover") if has_theme_constant("bounds_margin", "RookframePopover") else 8
	var gap := get_theme_constant("anchor_gap", "RookframePopover") if has_theme_constant("anchor_gap", "RookframePopover") else 8
	var bounds := Rect2(Vector2.ZERO, _anchor.get_viewport_rect().size)
	var anchor_rect := _anchor.get_global_rect()
	if not is_embedded():
		anchor_rect.position = _anchor.get_screen_position()
		bounds = Rect2(DisplayServer.screen_get_usable_rect(_owner_window.current_screen))
	bounds = bounds.grow(-margin)
	var desired := get_content_slot().get_combined_minimum_size() + Vector2(24, 24)
	var preferred_width := get_theme_constant("minimum_width", "RookframePopover") if has_theme_constant("minimum_width", "RookframePopover") else 320
	desired.x = maxf(desired.x, preferred_width)
	var target_size := desired.min(bounds.size).max(Vector2.ONE)
	var below := bounds.end.y - anchor_rect.end.y - gap
	var above := anchor_rect.position.y - bounds.position.y - gap
	var y := anchor_rect.end.y + gap
	if below < target_size.y and above > below: y = anchor_rect.position.y - gap - target_size.y
	position = Vector2i(Vector2(clampf(anchor_rect.position.x, bounds.position.x, bounds.end.x - target_size.x), clampf(y, bounds.position.y, bounds.end.y - target_size.y)))
	size = Vector2i(target_size)

func _exit_tree() -> void:
	_open = false
	_anchor = null
	_owner_window = null
