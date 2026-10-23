@tool
extends VBoxContainer

## Persistent HUD bar: leading action, identity, a lane of tiles, a trailing
## action and an optional attached panel. Profiles change visibility and
## properties only; caller children keep their parent, index and connections.

signal layout_profile_changed(profile: StringName)
signal overflow_opened

const ActionRow = preload("res://rookframe/ui/components/data/action_row.tscn")
const SLOTS: Array[NodePath] = [
	^"Bar/Row/LeadingSlot", ^"Bar/Row/IdentitySlot", ^"Bar/Row/CategorySlot",
	^"Bar/Row/TrailingSlot", ^"AttachedPanel/AttachedSlot",
]

@export_range(320.0, 3840.0, 4.0, "suffix:px") var medium_width := 1180.0:
	set(value):
		medium_width = value
		_apply_profile()

@export_range(320.0, 3840.0, 4.0, "suffix:px") var compact_width := 900.0:
	set(value):
		compact_width = value
		_apply_profile()

## -1 never moves tiles into the overflow popover.
@export_range(-1, 32) var compact_category_limit := -1:
	set(value):
		compact_category_limit = value
		_queue_layout()

@export var more_text := "More":
	set(value):
		more_text = value
		_queue_layout()

@export var more_icon: Texture2D = preload("res://rookframe/ui/icons/menu.svg"):
	set(value):
		more_icon = value
		_queue_layout()

var _profile: StringName = &"wide"
var _overflowed: Array[Control] = []
var _layout_pending := false
var _updating := false
var _parent_control: Control
var _viewport: Viewport


func _enter_tree() -> void:
	preload("res://rookframe/ui/_internal/presentation/binding.gd").attach(self)
	_parent_control = get_parent() as Control
	if _parent_control != null:
		_parent_control.resized.connect(_apply_profile)
	_viewport = get_viewport()
	if _viewport != null:
		_viewport.size_changed.connect(_apply_profile)


func _exit_tree() -> void:
	if is_instance_valid(_parent_control) and _parent_control.resized.is_connected(_apply_profile):
		_parent_control.resized.disconnect(_apply_profile)
	if is_instance_valid(_viewport) and _viewport.size_changed.is_connected(_apply_profile):
		_viewport.size_changed.disconnect(_apply_profile)
	_parent_control = null
	_viewport = null


func _ready() -> void:
	for path in SLOTS:
		var slot := get_node(path) as Container
		slot.child_entered_tree.connect(_slot_child_entered)
		slot.child_exiting_tree.connect(_slot_child_exiting)
		for child in slot.get_children():
			_slot_child_entered(child)
	%More.pressed.connect(_open_overflow)
	_apply_profile()


func get_leading_slot() -> Container:
	return %LeadingSlot


func get_identity_slot() -> Container:
	return %IdentitySlot


func get_category_slot() -> Container:
	return %CategorySlot


func get_trailing_slot() -> Container:
	return %TrailingSlot


func get_attached_slot() -> Container:
	return %AttachedSlot


func get_profile() -> StringName:
	return _profile


func close_overflow() -> void:
	var popover := get_node_or_null(^"Overflow")
	if popover != null and popover.has_method(&"is_open") and popover.is_open():
		popover.close(&"host")


func _apply_profile() -> void:
	if not is_node_ready():
		return
	# The bar shrinks to its content, so measure the space it is placed in.
	var width := get_parent_area_size().x
	var next: StringName = &"wide" if width >= medium_width else &"medium" if width >= compact_width else &"compact"
	var changed := next != _profile
	_profile = next
	var suffix := "" if _profile == &"wide" else "__" + String(_profile)
	# The root's separation is the gap between the attached panel and the bar.
	theme_type_variation = StringName("RookframeHud" + suffix)
	$Bar.theme_type_variation = StringName("RookframeHudBar" + suffix)
	$Bar/Row.theme_type_variation = StringName("RookframeHudBar" + suffix)
	$AttachedPanel.theme_type_variation = StringName("RookframeHudAttached" + suffix)
	_update_layout()
	if changed:
		layout_profile_changed.emit(_profile)


func _slot_child_entered(child: Node) -> void:
	if child is CanvasItem and not child.visibility_changed.is_connected(_queue_layout):
		child.visibility_changed.connect(_queue_layout)
	if child.has_method("set_compact"):
		child.set_compact(_profile == &"compact")
	_queue_layout()


func _slot_child_exiting(child: Node) -> void:
	if child is CanvasItem and child.visibility_changed.is_connected(_queue_layout):
		child.visibility_changed.disconnect(_queue_layout)
	if child is Control:
		_overflowed.erase(child)
	_queue_layout()


func _queue_layout() -> void:
	if _updating or _layout_pending or not is_node_ready():
		return
	_layout_pending = true
	_update_layout.call_deferred()


func _update_layout() -> void:
	_layout_pending = false
	if not is_inside_tree() or _updating:
		return
	_updating = true
	var compact := _profile == &"compact"
	for path in SLOTS:
		for child in get_node(path).get_children():
			if child.has_method("set_compact"):
				child.set_compact(compact)
	%More.set_compact(compact)
	_update_overflow(compact and compact_category_limit >= 0)
	for slot in [%LeadingSlot, %IdentitySlot, %CategorySlot, %TrailingSlot]:
		slot.visible = _has_visible_child(slot)
	$AttachedPanel.visible = _has_visible_child(%AttachedSlot)
	$Bar/Row/Divider.visible = %IdentitySlot.visible and %CategorySlot.visible
	_updating = false


func _update_overflow(enabled: bool) -> void:
	# Hide only tiles beyond the limit; a tile the caller hid is never counted or restored.
	var hidden: Array[Control] = []
	if enabled:
		var shown := 0
		for child in %CategorySlot.get_children():
			if not child is Control or not (child.visible or child in _overflowed):
				continue
			shown += 1
			if shown > compact_category_limit:
				hidden.append(child)
	for tile in _overflowed:
		if is_instance_valid(tile) and tile not in hidden:
			tile.visible = true
	for tile in hidden:
		tile.visible = false
	_overflowed = hidden
	var more := %More as Button
	more.text = more_text
	more.icon = more_icon
	more.visible = not _overflowed.is_empty()
	if _overflowed.is_empty():
		close_overflow()


func _has_visible_child(slot: Node) -> bool:
	for child in slot.get_children():
		if child is CanvasItem and child.visible and not child.is_queued_for_deletion():
			return true
	return false


func _open_overflow() -> void:
	var popover := get_node(^"Overflow")
	var content: Container = popover.get_content_slot()
	for row in content.get_children():
		content.remove_child(row)
		row.queue_free()
	# Rebuild on every open so copy and availability follow the original tiles.
	var first_row: Control
	for tile in _overflowed:
		if not is_instance_valid(tile):
			continue
		var row := ActionRow.instantiate()
		row.title = tile.text
		row.description = ""
		row.action_label = ""
		row.disabled = tile.disabled
		row.pressed.connect(_forward.bind(tile))
		content.add_child(row)
		if first_row == null and not row.disabled:
			first_row = row
	if popover.open_for(%More, first_row):
		overflow_opened.emit()


func _forward(tile: BaseButton) -> void:
	# Closing returns focus to More; the original tile keeps native group rules.
	close_overflow()
	if not is_instance_valid(tile) or tile.disabled:
		return
	if tile.toggle_mode:
		tile.button_pressed = not tile.button_pressed
	else:
		tile.pressed.emit()
