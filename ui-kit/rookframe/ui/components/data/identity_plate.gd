@tool
extends Button

## Portrait, name and detail as one native button target, with an optional
## display-only vital below the copy. The caller connects the inherited pressed signal.

const COPY_WIDTH := 240

@export var title := "Name":
	set(value):
		title = value
		_refresh()

@export_multiline var detail := "":
	set(value):
		detail = value
		_refresh()

@export var portrait: Texture2D:
	set(value):
		portrait = value
		_refresh()

@export var initials := "":
	set(value):
		initials = value
		_refresh()

@export var compact := false:
	set(value):
		compact = value
		_refresh()

var _refreshing := false
var _managed_minimum := Vector2(44, 44)
var _caller_minimum := Vector2.ZERO


func _enter_tree() -> void:
	preload("res://rookframe/ui/_internal/presentation/binding.gd").attach(self)


func _ready() -> void:
	var slot := get_vital_slot()
	slot.child_entered_tree.connect(_vital_entered)
	slot.child_exiting_tree.connect(_vital_exiting)
	for child in slot.get_children():
		_vital_entered(child)
	$Content.minimum_size_changed.connect(_fit_content)
	_refresh()


func set_compact(enabled: bool) -> void:
	compact = enabled


func get_vital_slot() -> Container:
	return %VitalSlot


func _notification(what: int) -> void:
	if what in [NOTIFICATION_THEME_CHANGED, NOTIFICATION_TRANSLATION_CHANGED] and is_node_ready() and not _refreshing:
		_refresh()


func _refresh() -> void:
	if not is_node_ready() or _refreshing:
		return
	_refreshing = true
	theme_type_variation = &"RookframeHudIdentity__compact" if compact else &"RookframeHudIdentity"
	var avatar := $Content/Row/Portrait
	avatar.texture = portrait
	avatar.initials = initials
	$Content/Row/Copy/Title.text = title
	$Content/Row/Copy/Detail.text = detail
	$Content/Row/Copy/Detail.visible = not detail.is_empty()
	accessibility_name = tr(title) + (", " + tr(detail) if not detail.is_empty() else "")
	_refresh_vital_slot()
	_refreshing = false
	_fit_content()


func _fit_content() -> void:
	var content := $Content as Control
	# Native Button styleboxes do not lay out children; inset the copy by their content margins.
	var style := get_theme_stylebox("normal")
	content.offset_left = style.get_margin(SIDE_LEFT)
	content.offset_top = style.get_margin(SIDE_TOP)
	content.offset_right = -style.get_margin(SIDE_RIGHT)
	content.offset_bottom = -style.get_margin(SIDE_BOTTOM)
	var copy := $Content/Row/Copy as Control
	# Labels wrap between words up to a readable measure; the widest word stays whole.
	var measure := 0.0
	for label in [$Content/Row/Copy/Title, $Content/Row/Copy/Detail]:
		if label.visible:
			measure = maxf(measure, _copy_width(label))
	var copy_width := get_theme_constant("copy_width") if has_theme_constant("copy_width") else COPY_WIDTH
	copy.custom_minimum_size.x = minf(measure, copy_width)
	var height := 44
	if has_theme_constant("minimum_height"):
		height = maxi(height, get_theme_constant("minimum_height"))
	var needed := content.get_combined_minimum_size() + style.get_minimum_size()
	for axis in 2:
		if custom_minimum_size[axis] != _managed_minimum[axis]:
			_caller_minimum[axis] = custom_minimum_size[axis]
	_managed_minimum = needed.max(Vector2(height, height)).max(_caller_minimum)
	custom_minimum_size = _managed_minimum


func _copy_width(label: Label) -> float:
	var font := label.get_theme_font("font")
	var font_size := label.get_theme_font_size("font_size")
	var widest := 0.0
	for line in tr(label.text).split("\n"):
		widest = maxf(widest, font.get_string_size(line, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x)
	return ceilf(widest)


func _vital_entered(child: Node) -> void:
	if child is CanvasItem and not child.visibility_changed.is_connected(_refresh_vital_slot):
		child.visibility_changed.connect(_refresh_vital_slot)
	_refresh_vital_slot.call_deferred()


func _vital_exiting(child: Node) -> void:
	if child is CanvasItem and child.visibility_changed.is_connected(_refresh_vital_slot):
		child.visibility_changed.disconnect(_refresh_vital_slot)
	_refresh_vital_slot.call_deferred()


func _refresh_vital_slot() -> void:
	if not is_inside_tree():
		return
	var slot := get_vital_slot()
	var shown := false
	for child in slot.get_children():
		if child is CanvasItem and child.visible and not child.is_queued_for_deletion() and child.get_parent() == slot:
			shown = true
	slot.visible = shown
