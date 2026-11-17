@tool
extends VBoxContainer

## Fixed task hierarchy for a managed surface or application-owned task.

@export var eyebrow := "":
	set(value):
		eyebrow = value
		_refresh()

@export var title := "Task title":
	set(value):
		title = value
		_refresh()

@export var subtitle := "":
	set(value):
		subtitle = value
		_refresh()

@export var use_large_title := false:
	set(value):
		use_large_title = value
		_refresh()


func _ready() -> void:
	for slot: Container in [get_progress_slot(), get_tabs_slot()]:
		slot.child_entered_tree.connect(_slot_child_entered.bind(slot))
		slot.child_exiting_tree.connect(_slot_child_exiting.bind(slot))
		for child in slot.get_children():
			_slot_child_entered(child, slot)
		_refresh_slot(slot)
	_refresh()


func get_actions_slot() -> Container:
	return get_node(^"TitleRow/ActionsSlot") as Container


func get_progress_slot() -> Container:
	return get_node(^"ProgressSlot") as Container


func get_tabs_slot() -> Container:
	return get_node(^"TabsSlot") as Container


func _refresh() -> void:
	if not is_inside_tree():
		return
	var eyebrow_label := get_node_or_null(^"Eyebrow") as Label
	var title_label := get_node_or_null(^"TitleRow/Title") as Label
	var subtitle_label := get_node_or_null(^"Subtitle") as Label
	if eyebrow_label != null:
		eyebrow_label.text = eyebrow
		eyebrow_label.visible = not eyebrow.is_empty()
	if title_label != null:
		title_label.text = title
		title_label.theme_type_variation = &"RookframeTitle" if use_large_title else &"RookframeSubtitle"
		title_label.accessibility_name = title
	if subtitle_label != null:
		subtitle_label.text = subtitle
		subtitle_label.visible = not subtitle.is_empty()


## An empty slot takes no room, so the header keeps no gap for it.
func _refresh_slot(slot: Container) -> void:
	if not is_inside_tree():
		return
	var shown := false
	for child in slot.get_children():
		if child is CanvasItem and child.visible and not child.is_queued_for_deletion() and child.get_parent() == slot:
			shown = true
	slot.visible = shown


func _slot_child_entered(child: Node, slot: Container) -> void:
	var refresh := _refresh_slot.bind(slot)
	if child is CanvasItem and not child.visibility_changed.is_connected(refresh):
		child.visibility_changed.connect(refresh)
	refresh.call_deferred()


func _slot_child_exiting(child: Node, slot: Container) -> void:
	var refresh := _refresh_slot.bind(slot)
	if child is CanvasItem and child.visibility_changed.is_connected(refresh):
		child.visibility_changed.disconnect(refresh)
	refresh.call_deferred()


func _enter_tree() -> void:
	preload("res://rookframe/ui/_internal/presentation/binding.gd").attach(self)
