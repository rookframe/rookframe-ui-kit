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
	custom_minimum_size = $Content.get_combined_minimum_size().max(Vector2(44, maxi(44, get_theme_constant("minimum_height"))))


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
		var padding := "padding_x" if side in ["left", "right"] else "padding_y"
		var margin := get_theme_constant(padding) if has_theme_constant(padding) else int(get_theme_stylebox("normal").get_content_margin({"left": SIDE_LEFT, "right": SIDE_RIGHT, "top": SIDE_TOP, "bottom": SIDE_BOTTOM}[side]))
		$Content.add_theme_constant_override("margin_" + side, margin)
	$Content/Row.add_theme_constant_override("separation", get_theme_constant("selection_gap") if has_theme_constant("selection_gap") else get_theme_constant("separation", "HBoxContainer"))
	$Content/Row/Copy.add_theme_constant_override("separation", get_theme_constant("copy_gap") if has_theme_constant("copy_gap") else get_theme_constant("separation", "VBoxContainer"))
	$Content/Row/Copy.custom_minimum_size.x = get_theme_constant("copy_minimum_width")
	for role in ["title", "description"]:
		var label := _label(role)
		label.add_theme_font_override("font", get_theme_font(role + "_font") if has_theme_font(role + "_font") else get_theme_font("font", "Button"))
		label.add_theme_font_size_override("font_size", get_theme_font_size(role + "_size") if has_theme_font_size(role + "_size") else get_theme_font_size("font_size", "Button"))
		if has_theme_color("ink_shadow"):
			label.add_theme_color_override("font_shadow_color", get_theme_color("ink_shadow"))
			label.add_theme_constant_override("shadow_offset_y", get_theme_constant("ink_shadow_size"))
		else:
			label.remove_theme_color_override("font_shadow_color")
			label.remove_theme_constant_override("shadow_offset_y")
	# Keep the icon's space when unchecked so selection never shifts the copy.
	var mark := get_theme_icon("selection_mark") if has_theme_icon("selection_mark") else get_theme_icon("checked", "CheckBox")
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
	var disabled_mark := get_theme_color("selection_disabled") if has_theme_color("selection_disabled") else get_theme_color("font_disabled_color", "Button")
	$Content/Row/SelectionMark.self_modulate = Color.TRANSPARENT if not button_pressed else disabled_mark if disabled else Color.WHITE
	for role in ["title", "description"]:
		var slot := "disabled" if disabled else "selected" if button_pressed else state
		var native_slot: String = {"normal": "font_color", "hover": "font_hover_color", "pressed": "font_pressed_color", "hover_pressed": "font_hover_pressed_color", "disabled": "font_disabled_color", "selected": "font_pressed_color"}[slot]
		var color := get_theme_color(role + "_" + slot) if has_theme_color(role + "_" + slot) else get_theme_color(native_slot, "Button")
		var label := _label(role)
		if label.get_theme_color("font_color") != color:
			label.add_theme_color_override("font_color", color)
