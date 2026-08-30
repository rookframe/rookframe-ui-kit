@tool
extends VBoxContainer

## Responsive two-to-eight-step wizard progress. Wide layouts render a
## connected step rail; compact layouts keep the current step and completion.

signal layout_profile_changed(profile: StringName)

const CHECK_ICON := preload("res://rookframe/ui/icons/check.svg")

@export var accessible_label := "Workflow progress":
	set(value):
		accessible_label = value
		_refresh()

@export var steps := PackedStringArray(["First step", "Second step"]):
	set(value):
		steps = value
		_refresh()

@export_range(1, 8, 1) var current_step := 1:
	set(value):
		current_step = clampi(value, 1, 8)
		_refresh()

@export_range(480.0, 1200.0, 4.0, "suffix:px") var compact_width := 720.0:
	set(value):
		compact_width = maxf(480.0, value)
		_refresh()

var _profile: StringName = &"wide"
var _render_signature := ""


func _notification(what: int) -> void:
	if what == NOTIFICATION_READY or what == NOTIFICATION_RESIZED:
		_refresh()


func _normalized_steps() -> PackedStringArray:
	var normalized := steps.slice(0, mini(steps.size(), 8))
	if normalized.size() < 2:
		return PackedStringArray(["First step", "Second step"])
	return normalized


func _refresh() -> void:
	if not is_inside_tree():
		return
	var normalized_steps := _normalized_steps()
	var normalized_current := clampi(current_step, 1, normalized_steps.size())
	var required_rail_width := normalized_steps.size() * 112.0
	var use_compact := size.x > 0.0 and size.x < maxf(compact_width, required_rail_width)
	var wide := get_node_or_null(^"Wide") as VBoxContainer
	var compact := get_node_or_null(^"Compact") as PanelContainer
	if wide != null:
		wide.visible = not use_compact
	if compact != null:
		compact.visible = use_compact

	var signature := "%s|%d" % ["::".join(normalized_steps), normalized_current]
	if signature != _render_signature:
		_render_signature = signature
		_rebuild_wide(normalized_steps, normalized_current)
	_refresh_compact(normalized_steps, normalized_current)
	_refresh_accessibility(normalized_steps, normalized_current)

	var next_profile: StringName = &"compact" if use_compact else &"wide"
	if _profile == next_profile:
		return
	_profile = next_profile
	layout_profile_changed.emit(_profile)


func _rebuild_wide(normalized_steps: PackedStringArray, normalized_current: int) -> void:
	var track := get_node_or_null(^"Wide/Track") as HBoxContainer
	var summary := get_node_or_null(^"Wide/Context/Summary") as Label
	var current_title := get_node_or_null(^"Wide/Context/CurrentTitle") as Label
	if track == null:
		return
	for child in track.get_children():
		track.remove_child(child)
		child.queue_free()
	if summary != null:
		summary.text = "STEP %d OF %d" % [normalized_current, normalized_steps.size()]
	if current_title != null:
		current_title.text = normalized_steps[normalized_current - 1]

	for index in range(normalized_steps.size()):
		var position := index + 1
		var state_name := "complete" if position < normalized_current else ("current" if position == normalized_current else "pending")
		var cell := VBoxContainer.new()
		cell.name = "Step%d" % position
		cell.custom_minimum_size.x = 112
		cell.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		cell.add_theme_constant_override(&"separation", 8)
		cell.accessibility_name = "Step %d, %s, %s" % [position, normalized_steps[index], state_name]
		track.add_child(cell)

		var rail := HBoxContainer.new()
		rail.name = "Rail"
		rail.add_theme_constant_override(&"separation", 0)
		cell.add_child(rail)

		var left := _connector("Connector%dLeft" % position)
		left.color = _connector_color(position <= normalized_current)
		if position == 1:
			left.modulate.a = 0.0
		rail.add_child(left)

		var marker := PanelContainer.new()
		marker.name = "Marker%d" % position
		marker.custom_minimum_size = Vector2(36, 36)
		marker.mouse_filter = Control.MOUSE_FILTER_IGNORE
		marker.theme_type_variation = _marker_variation(state_name)
		rail.add_child(marker)
		if state_name == "complete":
			var icon := TextureRect.new()
			icon.name = "Check"
			icon.texture = CHECK_ICON
			icon.custom_minimum_size = Vector2(20, 20)
			icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
			marker.add_child(icon)
		else:
			var number := Label.new()
			number.name = "Number"
			number.text = str(position)
			number.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			number.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			number.theme_type_variation = &"RookframePending" if state_name == "current" else &"RookframeMeta"
			number.mouse_filter = Control.MOUSE_FILTER_IGNORE
			marker.add_child(number)

		var right := _connector("Connector%dRight" % position)
		right.color = _connector_color(position < normalized_current)
		if position == normalized_steps.size():
			right.modulate.a = 0.0
		rail.add_child(right)

		var label := Label.new()
		label.name = "Label"
		label.text = normalized_steps[index]
		label.custom_minimum_size.y = 42
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.theme_type_variation = _label_variation(state_name)
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		cell.add_child(label)


func _connector(node_name: String) -> ColorRect:
	var connector := ColorRect.new()
	connector.name = node_name
	connector.custom_minimum_size.y = 2
	connector.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	connector.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	connector.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return connector


func _connector_color(complete: bool) -> Color:
	return RookframeUiTokens.COLOR_SUCCESS if complete else RookframeUiTokens.COLOR_RULE


func _marker_variation(state_name: String) -> StringName:
	match state_name:
		"complete":
			return &"RookframeStepComplete"
		"current":
			return &"RookframeStepCurrent"
		_:
			return &"RookframeStepPending"


func _label_variation(state_name: String) -> StringName:
	match state_name:
		"complete":
			return &"RookframeSuccess"
		"current":
			return &"RookframePending"
		_:
			return &"RookframeMeta"


func _refresh_compact(normalized_steps: PackedStringArray, normalized_current: int) -> void:
	var current_number := get_node_or_null(^"Compact/Content/Row/CurrentMarker/CurrentNumber") as Label
	var summary := get_node_or_null(^"Compact/Content/Row/Copy/CompactSummary") as Label
	var title := get_node_or_null(^"Compact/Content/Row/Copy/CompactTitle") as Label
	var percent := get_node_or_null(^"Compact/Content/Row/Percent") as Label
	var progress := get_node_or_null(^"Compact/Content/Progress") as ProgressBar
	if current_number != null:
		current_number.text = str(normalized_current)
	if summary != null:
		summary.text = "STEP %d OF %d" % [normalized_current, normalized_steps.size()]
	if title != null:
		title.text = normalized_steps[normalized_current - 1]
	if percent != null:
		percent.text = "%d%%" % roundi(float(normalized_current) / normalized_steps.size() * 100.0)
	if progress != null:
		progress.max_value = normalized_steps.size()
		progress.value = normalized_current
		progress.accessibility_name = accessible_label
		progress.accessibility_description = summary.text + ": " + title.text


func _refresh_accessibility(normalized_steps: PackedStringArray, normalized_current: int) -> void:
	accessibility_name = accessible_label
	var states := PackedStringArray()
	for index in range(normalized_steps.size()):
		var position := index + 1
		var state_name := "complete" if position < normalized_current else ("current" if position == normalized_current else "pending")
		states.append("%s, %s" % [normalized_steps[index], state_name])
	accessibility_description = "Step %d of %d. %s" % [normalized_current, normalized_steps.size(), "; ".join(states)]
