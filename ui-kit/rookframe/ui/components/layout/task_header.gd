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
