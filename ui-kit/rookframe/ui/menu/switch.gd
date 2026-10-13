@tool
extends Button
## A selectable card. Native Button and ButtonGroup own input and selection.
const USAGE: StringName = &"components.switch"
@export var title := "Option":
	set(value):
		title = value
		_refresh()
@export_multiline var description := "":
	set(value):
		description = value
		_refresh()
@export var compact := false:
	set(value):
		compact = value
		_refresh()
var _refresh_pending := false
var _configuring := false
var _automatic_name := ""
var _automatic_description := ""


func _ready() -> void:
	$Content.minimum_size_changed.connect(_fit_content)
	toggled.connect(func(_selected: bool) -> void: _update_state())
	_refresh()


func set_compact(enabled: bool) -> void:
	compact = enabled


func _fit_content() -> void:
	# Button supplies its own native minimum; child copy needs an explicit bound.
	custom_minimum_size = $Content.get_combined_minimum_size().max(Vector2(0, get_theme_constant("minimum_height")))


func _notification(what: int) -> void:
	if what in [NOTIFICATION_THEME_CHANGED, NOTIFICATION_TRANSLATION_CHANGED] and is_node_ready() and not _configuring and not _refresh_pending:
		_refresh_pending = true
		_refresh.call_deferred()
	if what == NOTIFICATION_DRAW and is_node_ready():
		_update_state()


func _refresh() -> void:
	if not is_node_ready():
		return
	_configuring = true
	_refresh_pending = false
	theme_type_variation = String(USAGE).replace(".", "_") + ("__compact" if compact else "")
	$Content/Row/Copy/Title.text = title
	$Content/Row/Copy/Description.text = description
	$Content/Row/Copy/Description.visible = not description.is_empty()
	if accessibility_name.is_empty() or accessibility_name == _automatic_name:
		accessibility_name = tr(title)
		_automatic_name = accessibility_name
	if accessibility_description.is_empty() or accessibility_description == _automatic_description:
		accessibility_description = tr(description)
		_automatic_description = accessibility_description
	for side in ["left", "right", "top", "bottom"]:
		$Content.add_theme_constant_override("margin_" + side, get_theme_constant("padding_x" if side in ["left", "right"] else "padding_y"))
	$Content/Row.add_theme_constant_override("separation", get_theme_constant("selection_gap"))
	$Content/Row/Copy.add_theme_constant_override("separation", get_theme_constant("copy_gap"))
	$Content/Row/Copy.custom_minimum_size.x = get_theme_constant("copy_minimum_width")
	for role in ["title", "description"]:
		var label := _label(role)
		label.add_theme_font_override("font", get_theme_font(role + "_font"))
		label.add_theme_font_size_override("font_size", get_theme_font_size(role + "_size"))
		label.add_theme_color_override("font_shadow_color", get_theme_color("ink_shadow"))
		label.add_theme_constant_override("shadow_offset_y", get_theme_constant("ink_shadow_size"))
	# Keep the icon's space when unchecked so selection never shifts the copy.
	var mark := get_theme_icon("selection_mark")
	$Content/Row/SelectionMark.texture = mark
	$Content/Row/SelectionMark.custom_minimum_size = mark.get_size()
	_update_state()
	_fit_content()
	_configuring = false


func _label(role: String) -> Label:
	return $Content/Row/Copy/Title if role == "title" else $Content/Row/Copy/Description


func _update_state() -> void:
	var state: String = {DRAW_NORMAL: "normal", DRAW_HOVER: "hover", DRAW_PRESSED: "pressed", DRAW_HOVER_PRESSED: "hover_pressed", DRAW_DISABLED: "disabled"}[get_draw_mode()]
	mouse_default_cursor_shape = CURSOR_ARROW if disabled else CURSOR_POINTING_HAND
	$Content/Row/SelectionMark.self_modulate = Color.TRANSPARENT if not button_pressed else get_theme_color("selection_disabled") if disabled else Color.WHITE
	for role in ["title", "description"]:
		var slot := "disabled" if disabled else "selected" if button_pressed else state
		var color := get_theme_color(role + "_" + slot)
		var label := _label(role)
		if label.get_theme_color("font_color") != color:
			label.add_theme_color_override("font_color", color)
