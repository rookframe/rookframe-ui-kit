@tool
extends PanelContainer

## Retained surface anatomy with fixed header/footer, one scrolling body,
## serializable docking/floating state, and focus restoration.

signal placement_changed(placement: int)
signal minimized
signal restored
signal close_requested
signal lifecycle_changed(snapshot: Dictionary)

const PLACEMENT_DOCKED := 0
const PLACEMENT_FLOATING := 1
const DOCK_ICON := preload("res://rookframe/ui/icons/dock.svg")
const FLOAT_ICON := preload("res://rookframe/ui/icons/pop-out.svg")

@export var surface_title := "Managed surface":
	set(value):
		surface_title = value
		_refresh()

@export var state: RookframeManagedSurfaceState = RookframeManagedSurfaceState.new():
	set(value):
		_disconnect_state()
		state = value if value != null else RookframeManagedSurfaceState.new()
		_connect_state()
		_refresh()

var _last_focus_owner: Control


func _ready() -> void:
	_connect_state()
	var scroll := get_node(^"Sections/BodyRegion/BodyPadding/Body") as ScrollContainer
	var toggle := get_node(^"Sections/Chrome/Row/TogglePlacement") as Button
	var minimize_button := get_node(^"Sections/Chrome/Row/Minimize") as Button
	var close_button := get_node(^"Sections/Chrome/Row/Close") as Button
	if not scroll.get_v_scroll_bar().value_changed.is_connected(_on_scroll_changed):
		scroll.get_v_scroll_bar().value_changed.connect(_on_scroll_changed)
	if not toggle.pressed.is_connected(toggle_placement):
		toggle.pressed.connect(toggle_placement)
	if not minimize_button.pressed.is_connected(minimize_surface):
		minimize_button.pressed.connect(minimize_surface)
	if not close_button.pressed.is_connected(_on_close_pressed):
		close_button.pressed.connect(_on_close_pressed)
	_connect_focus_tracking(get_task_slot())
	_refresh()


func get_header_slot() -> Container:
	return get_node(^"Sections/Header/HeaderSlot") as Container


func get_task_slot() -> Container:
	return get_node(^"Sections/BodyRegion/BodyPadding/Body/TaskSlot") as Container


func get_footer_slot() -> Container:
	return get_node(^"Sections/Footer/FooterSlot") as Container


func set_task(task: Control) -> Control:
	var slot := get_task_slot()
	var previous: Control
	if slot.get_child_count() > 0:
		previous = slot.get_child(0) as Control
		if previous == task:
			return previous
		_disconnect_focus_tracking(previous)
		slot.remove_child(previous)
	if task != null:
		var existing_parent := task.get_parent()
		if existing_parent != null:
			existing_parent.remove_child(task)
		slot.add_child(task)
		_connect_focus_tracking(task)
	return previous


func open_surface() -> void:
	state.open_surface()
	_refresh()
	_restore_focus()


func close_surface() -> void:
	_capture_focus()
	state.close_surface()
	_refresh()


func minimize_surface() -> void:
	_capture_focus()
	if state.minimize_surface():
		_refresh()
		minimized.emit()


func restore_surface() -> void:
	if state.restore_surface():
		_refresh()
		_restore_focus()
		restored.emit()


func set_placement(placement: int) -> void:
	state.set_placement(placement)
	_refresh()
	placement_changed.emit(state.placement)


func toggle_placement() -> void:
	var next := PLACEMENT_FLOATING if state.placement == PLACEMENT_DOCKED else PLACEMENT_DOCKED
	set_placement(next)


func set_dock_width(width: float) -> void:
	state.set_dock_width(width)


func set_floating_rect(rect: Rect2) -> void:
	state.set_floating_rect(rect)


func capture_state() -> Dictionary:
	_sync_scroll_state()
	return state.state_snapshot()


func restore_state(snapshot: Dictionary) -> void:
	state.restore_snapshot(snapshot)
	_refresh()
	if state.focused and state.is_visible():
		_restore_focus()


func focus_task() -> void:
	var focusable := _first_focusable(get_task_slot())
	if focusable != null:
		focusable.grab_focus()


func _on_close_pressed() -> void:
	close_surface()
	close_requested.emit()


func _on_scroll_changed(value: float) -> void:
	state.set_scroll_offset(value)


func _on_state_changed(snapshot: Dictionary) -> void:
	lifecycle_changed.emit(snapshot)


func _on_focus_entered(control: Control) -> void:
	_last_focus_owner = control
	state.focus_surface()


func _connect_state() -> void:
	if state == null:
		return
	if not state.state_changed.is_connected(_on_state_changed):
		state.state_changed.connect(_on_state_changed)


func _disconnect_state() -> void:
	if state == null:
		return
	if state.state_changed.is_connected(_on_state_changed):
		state.state_changed.disconnect(_on_state_changed)


func _connect_focus_tracking(node: Node) -> void:
	if node is Control:
		var control := node as Control
		if control.focus_mode != Control.FOCUS_NONE and not control.focus_entered.is_connected(_on_focus_entered.bind(control)):
			control.focus_entered.connect(_on_focus_entered.bind(control))
	for child in node.get_children():
		_connect_focus_tracking(child)


func _disconnect_focus_tracking(node: Node) -> void:
	if node is Control:
		var control := node as Control
		var callback := _on_focus_entered.bind(control)
		if control.focus_entered.is_connected(callback):
			control.focus_entered.disconnect(callback)
	for child in node.get_children():
		_disconnect_focus_tracking(child)


func _capture_focus() -> void:
	var owner := get_viewport().gui_get_focus_owner()
	if owner is Control and get_task_slot().is_ancestor_of(owner):
		_last_focus_owner = owner


func _restore_focus() -> void:
	if _last_focus_owner != null and is_instance_valid(_last_focus_owner) and _last_focus_owner.is_visible_in_tree():
		_last_focus_owner.call_deferred(&"grab_focus")
	else:
		call_deferred(&"focus_task")


func _first_focusable(node: Node) -> Control:
	if node is Control:
		var control := node as Control
		if control.focus_mode != Control.FOCUS_NONE and control.visible and control.mouse_filter != Control.MOUSE_FILTER_IGNORE:
			return control
	for child in node.get_children():
		var found := _first_focusable(child)
		if found != null:
			return found
	return null


func _sync_scroll_state() -> void:
	var scroll := get_node_or_null(^"Sections/BodyRegion/BodyPadding/Body") as ScrollContainer
	if scroll != null:
		state.set_scroll_offset(scroll.scroll_vertical)


func _refresh() -> void:
	if not is_inside_tree() or state == null:
		return
	var title_label := get_node_or_null(^"Sections/Chrome/Row/Title") as Label
	var toggle := get_node_or_null(^"Sections/Chrome/Row/TogglePlacement") as Button
	var scroll := get_node_or_null(^"Sections/BodyRegion/BodyPadding/Body") as ScrollContainer
	if title_label != null:
		title_label.text = surface_title
	if toggle != null:
		var floating := state.placement == PLACEMENT_FLOATING
		toggle.tooltip_text = "Dock surface" if floating else "Float surface"
		toggle.accessibility_name = toggle.tooltip_text
		toggle.icon = DOCK_ICON if floating else FLOAT_ICON
	visible = state.is_visible()
	if scroll != null:
		scroll.scroll_vertical = roundi(state.scroll_offset)
	accessibility_name = surface_title
	accessibility_description = "Managed surface with one scrolling task body"
