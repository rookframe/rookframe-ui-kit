@tool
extends HBoxContainer
## One native input with retained leading/trailing context and action slots.
var _focused: WeakRef
var _prior_focus_style: StyleBox
var _had_focus_override := false
var _empty_focus := StyleBoxEmpty.new()

func _ready() -> void:
	get_viewport().gui_focus_changed.connect(_focus_changed)
	child_order_changed.connect(queue_redraw)
	%InputSlot.child_entered_tree.connect(_input_added)
	for child in %InputSlot.get_children(): _input_added(child)
	queue_redraw()

func get_leading_slot() -> Container:
	return %LeadingSlot

func get_input_slot() -> Container:
	return %InputSlot

func get_trailing_slot() -> Container:
	return %TrailingSlot

func _input_added(child: Node) -> void:
	if child is Control: child.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if %InputSlot.get_child_count() > 1:
		push_error("InputGroup: InputSlot accepts one input control")

func _focus_changed(control: Control) -> void:
	_restore_inner_focus()
	if control != null and is_ancestor_of(control):
		_focused = weakref(control)
		_had_focus_override = control.has_theme_stylebox_override("focus")
		_prior_focus_style = control.get_theme_stylebox("focus") if _had_focus_override else null
		control.add_theme_stylebox_override("focus", _empty_focus)
	queue_redraw()

func _restore_inner_focus() -> void:
	var control: Control = _focused.get_ref() if _focused != null else null
	if control != null and control.get_theme_stylebox("focus") == _empty_focus:
		if _had_focus_override: control.add_theme_stylebox_override("focus", _prior_focus_style)
		else: control.remove_theme_stylebox_override("focus")
	_focused = null
	_prior_focus_style = null

func _draw() -> void:
	if not is_inside_tree(): return
	var focused := get_viewport().gui_get_focus_owner()
	if focused != null and is_ancestor_of(focused):
		draw_style_box(get_theme_stylebox("focus", "Button"), Rect2(Vector2.ZERO, size))

func _exit_tree() -> void:
	_restore_inner_focus()
	if get_viewport().gui_focus_changed.is_connected(_focus_changed):
		get_viewport().gui_focus_changed.disconnect(_focus_changed)
