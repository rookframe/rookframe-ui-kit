@tool
extends RefCounted
## Token-built base layer: every standard stock control and kit type variation,
## generated from one Theme's `RookframeTokens`. `component_theme.gd` lays it
## beneath a theme's own sources, for the types those sources leave undefined.
##
## Nothing here is authored appearance. Colors come from color roles, fonts and
## sizes from type roles, paddings from `space_*`, corners, borders and focus
## from shape tokens, shadows from elevation and `shadow`. Mixing weights and
## opacity are the only numbers. Icons stay Godot's own, tinted by color roles.
const Tokens = preload("design_tokens.gd")

const BUTTON_STATES: Array[StringName] = [&"normal", &"hover", &"pressed", &"hover_pressed", &"disabled"]
## Opacity of a disabled fill or border against the surface beneath it.
const DISABLED_OPACITY := 0.5
## Share of a status color mixed into its surface under the pointer and while pressed.
const STATUS_HOVER := 0.16
const STATUS_PRESSED := 0.3

var _tokens: Theme
var _theme := Theme.new()

## A new Theme holding the base layer for the tokens `tokens` resolves.
static func build(tokens: Theme) -> Theme:
	var builder := new()
	builder._tokens = tokens
	builder._text()
	builder._buttons()
	builder._fields()
	builder._surfaces()
	builder._lists()
	builder._ranges()
	builder._kit_text()
	builder._kit_actions()
	builder._kit_surfaces()
	builder._kit_tabletop()
	builder._kit_tasks()
	return builder._theme

# Token reads.

func _c(token: StringName) -> Color:
	return _tokens.get_color(token, Tokens.TYPE)

func _k(token: StringName) -> int:
	return _tokens.get_constant(token, Tokens.TYPE)

func _s(step: int) -> int:
	return _k(StringName("space_%d" % step))

func _clear(color: Color) -> Color:
	return Color(color, 0.0)

func _faded(color: Color, opacity := DISABLED_OPACITY) -> Color:
	return Color(color, color.a * opacity)

# Item writers.

func _vary(type: StringName, base: StringName) -> void:
	_theme.set_type_variation(type, base)

func _style(type: StringName, item: StringName, box: StyleBox) -> void:
	_theme.set_stylebox(item, type, box)

func _styles(type: StringName, items: Array, box: StyleBox) -> void:
	for item in items:
		_theme.set_stylebox(item, type, box)

func _color(type: StringName, item: StringName, color: Color) -> void:
	_theme.set_color(item, type, color)

func _colors(type: StringName, items: Array, color: Color) -> void:
	for item in items:
		_theme.set_color(item, type, color)

func _constant(type: StringName, item: StringName, value: int) -> void:
	_theme.set_constant(item, type, value)

## A type role's font and size under the item names a control reads.
func _type(type: StringName, role: StringName, font_item := &"font", size_item := &"font_size") -> void:
	_theme.set_font(font_item, type, _tokens.get_font(role, Tokens.TYPE))
	_theme.set_font_size(size_item, type, _tokens.get_font_size(role, Tokens.TYPE))

# StyleBoxes.

## Filled, outlined box. `width` and `radius` default to `border_width` and `radius_small`.
func _box(fill: Color, border: Color, horizontal := 0, vertical := 0, radius := -1, width := -1) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = fill
	box.draw_center = fill.a > 0.0
	box.border_color = border
	box.set_border_width_all(_k(&"border_width") if width < 0 else width)
	box.set_corner_radius_all(_k(&"radius_small") if radius < 0 else radius)
	_pad(box, horizontal, vertical)
	return box

func _pad(box: StyleBox, horizontal: int, vertical: int) -> StyleBox:
	box.content_margin_left = horizontal
	box.content_margin_right = horizontal
	box.content_margin_top = vertical
	box.content_margin_bottom = vertical
	return box

## Keeps the outline on the named sides only: a rule rather than a frame.
func _sides(box: StyleBoxFlat, left: bool, top: bool, right: bool, bottom: bool, width := -1) -> StyleBoxFlat:
	var size := _k(&"border_width") if width < 0 else width
	box.border_width_left = size if left else 0
	box.border_width_top = size if top else 0
	box.border_width_right = size if right else 0
	box.border_width_bottom = size if bottom else 0
	box.set_corner_radius_all(0)
	return box

func _rule(fill: Color, horizontal := 0, vertical := 0) -> StyleBoxFlat:
	return _sides(_box(fill, _c(&"divider"), horizontal, vertical), false, false, false, true)

func _lifted(box: StyleBoxFlat, elevation: StringName) -> StyleBoxFlat:
	box.shadow_color = _c(&"shadow")
	box.shadow_size = _k(elevation)
	return box

func _empty(horizontal := 0, vertical := 0) -> StyleBoxEmpty:
	return _pad(StyleBoxEmpty.new(), horizontal, vertical) as StyleBoxEmpty

func _focus(radius := -1) -> StyleBoxFlat:
	return _box(_clear(_c(&"focus_ring")), _c(&"focus_ring"), 0, 0, radius, _k(&"focus_width"))

func _line(color: Color, vertical := false) -> StyleBoxLine:
	var line := StyleBoxLine.new()
	line.color = color
	line.thickness = _k(&"border_width")
	line.vertical = vertical
	return line

# Recipes.

## All Button states. `fills`, `borders` and `inks` hold normal, hover and pressed.
func _button(type: StringName, fills: Array, borders: Array, inks: Array, horizontal: int, vertical: int, radius := -1) -> void:
	for index in 3:
		_style(type, BUTTON_STATES[index], _box(fills[index], borders[index], horizontal, vertical, radius))
	_style(type, &"hover_pressed", _box(fills[2], borders[1], horizontal, vertical, radius))
	_style(type, &"disabled", _box(_faded(fills[0]), _faded(borders[0]), horizontal, vertical, radius))
	_style(type, &"focus", _focus(radius))
	_inks(type, inks)

## Text and icon colors of a Button: normal, hover and pressed.
func _inks(type: StringName, inks: Array) -> void:
	_colors(type, [&"font_color", &"icon_normal_color"], inks[0])
	_colors(type, [&"font_hover_color", &"font_focus_color", &"icon_hover_color", &"icon_focus_color"], inks[1])
	_colors(type, [&"font_pressed_color", &"font_hover_pressed_color", &"icon_pressed_color", &"icon_hover_pressed_color"], inks[2])
	_colors(type, [&"font_disabled_color", &"icon_disabled_color"], _c(&"content_disabled"))

func _secondary(type: StringName, horizontal: int, vertical: int, radius := -1) -> void:
	_button(type, [_c(&"surface_raised"), _c(&"surface_hover"), _c(&"surface_pressed")],
		[_c(&"border"), _c(&"border_strong"), _c(&"accent")],
		[_c(&"content"), _c(&"content"), _c(&"content")], horizontal, vertical, radius)

func _primary(type: StringName, horizontal: int, vertical: int, radius := -1) -> void:
	_button(type, [_c(&"accent"), _c(&"accent_hover"), _c(&"accent_pressed")],
		[_c(&"accent"), _c(&"accent_hover"), _c(&"accent_pressed")],
		[_c(&"accent_content"), _c(&"accent_content"), _c(&"accent_content")], horizontal, vertical, radius)
	_style(type, &"disabled", _box(_faded(_c(&"surface_raised")), _faded(_c(&"border")), horizontal, vertical, radius))

func _quiet(type: StringName, horizontal: int, vertical: int, radius := -1) -> void:
	var none := _clear(_c(&"surface_hover"))
	_button(type, [none, _c(&"surface_hover"), _c(&"surface_pressed")], [none, none, none],
		[_c(&"content"), _c(&"content"), _c(&"content")], horizontal, vertical, radius)

func _destructive(type: StringName, horizontal: int, vertical: int, outline := false) -> void:
	var rest := _clear(_c(&"danger_surface")) if outline else _c(&"danger_surface")
	_button(type, [rest, _c(&"danger_surface").lerp(_c(&"danger"), STATUS_HOVER), _c(&"danger_surface").lerp(_c(&"danger"), STATUS_PRESSED)],
		[_c(&"danger"), _c(&"danger"), _c(&"danger")],
		[_c(&"danger") if outline else _c(&"danger_content"), _c(&"danger_content"), _c(&"danger_content")], horizontal, vertical)

## A row that reads as content until pointed at; pressed marks the selection.
func _row(type: StringName, horizontal: int, vertical: int) -> void:
	_style(type, &"normal", _rule(_clear(_c(&"surface_hover")), horizontal, vertical))
	_style(type, &"hover", _rule(_c(&"surface_hover"), horizontal, vertical))
	_styles(type, [&"pressed", &"hover_pressed"], _rule(_c(&"accent_subtle"), horizontal, vertical))
	_style(type, &"disabled", _rule(_clear(_c(&"surface_hover")), horizontal, vertical))
	_style(type, &"focus", _focus())
	_inks(type, [_c(&"content"), _c(&"content"), _c(&"content")])

## A tab: an underline that takes the accent when selected.
func _tab(type: StringName, horizontal: int, vertical: int) -> void:
	_style(type, &"normal", _rule(_clear(_c(&"surface_hover")), horizontal, vertical))
	_style(type, &"hover", _rule(_c(&"surface_hover"), horizontal, vertical))
	_styles(type, [&"pressed", &"hover_pressed"], _selected_tab(horizontal, vertical))
	_style(type, &"disabled", _rule(_clear(_c(&"surface_hover")), horizontal, vertical))
	_style(type, &"focus", _focus())
	_inks(type, [_c(&"content_muted"), _c(&"content"), _c(&"content_heading")])

func _selected_tab(horizontal: int, vertical: int) -> StyleBoxFlat:
	var box := _box(_c(&"surface_pressed"), _c(&"accent"), horizontal, vertical)
	return _sides(box, false, false, false, true, _k(&"border_width_strong"))

func _label(type: StringName, role: StringName, ink: StringName) -> void:
	_vary(type, &"Label")
	_type(type, role)
	_color(type, &"font_color", _c(ink))
	_constant(type, &"line_spacing", _k(StringName("line_spacing_" + role)))

func _panel(type: StringName, box: StyleBox, base := &"PanelContainer") -> void:
	_vary(type, base)
	_style(type, &"panel", box)

func _surface(fill: StringName, pad := 0, border := &"border") -> StyleBoxFlat:
	return _box(_c(fill), _c(border), pad, pad)

func _status(type: StringName, role: String, pad: int) -> void:
	_panel(type, _box(_c(StringName(role + "_surface")), _c(StringName(role)), pad, pad))

# Stock controls.

func _text() -> void:
	_color(&"Label", &"font_color", _c(&"content"))
	_constant(&"Label", &"line_spacing", _k(&"line_spacing_body"))
	_color(&"RichTextLabel", &"default_color", _c(&"content"))
	_color(&"RichTextLabel", &"font_selected_color", _c(&"content"))
	_color(&"RichTextLabel", &"selection_color", _c(&"accent_subtle"))
	_color(&"RichTextLabel", &"table_border", _c(&"divider"))
	_constant(&"RichTextLabel", &"line_separation", _k(&"line_spacing_body"))
	_type(&"RichTextLabel", &"mono", &"mono_font", &"mono_font_size")
	_style(&"RichTextLabel", &"focus", _focus())
	_color(&"TooltipLabel", &"font_color", _c(&"content"))
	_type(&"TooltipLabel", &"meta")
	_style(&"TooltipPanel", &"panel", _box(_c(&"surface_raised"), _c(&"border"), _s(3), _s(2)))
	_color(&"LinkButton", &"font_color", _c(&"accent"))
	_colors(&"LinkButton", [&"font_hover_color", &"font_focus_color"], _c(&"accent_hover"))
	_color(&"LinkButton", &"font_pressed_color", _c(&"accent_pressed"))
	_style(&"LinkButton", &"focus", _focus())

func _buttons() -> void:
	_secondary(&"Button", _s(4), _s(2))
	_type(&"Button", &"label")
	_constant(&"Button", &"h_separation", _s(2))
	_quiet(&"MenuButton", _s(3), _s(2))
	_secondary(&"OptionButton", _s(4), _s(2))
	_constant(&"OptionButton", &"arrow_margin", _s(3))
	_constant(&"OptionButton", &"modulate_arrow", 1)
	for type: StringName in [&"CheckBox", &"CheckButton"]:
		# Godot's unchecked mark is a dark well, which only a lit row shows; the
		# checked mark carries the accent, so the row itself stays quiet.
		_button(type, [_c(&"surface_raised"), _c(&"surface_hover"), _c(&"surface_raised")],
			[_c(&"border"), _c(&"border_strong"), _c(&"border")],
			[_c(&"content"), _c(&"content"), _c(&"content")], _s(2), _s(1))
		_style(type, &"hover_pressed", _box(_c(&"surface_hover"), _c(&"border_strong"), _s(2), _s(1)))
		_constant(type, &"h_separation", _s(2))
	_color(&"CheckBox", &"checkbox_checked_color", _c(&"accent"))
	_color(&"CheckBox", &"checkbox_unchecked_color", _c(&"content"))
	_color(&"CheckButton", &"button_checked_color", _c(&"accent"))
	_color(&"CheckButton", &"button_unchecked_color", _c(&"content_muted"))
	_styles(&"MenuBar", [&"normal", &"disabled"], _empty(_s(3), _s(2)))
	_style(&"MenuBar", &"hover", _box(_c(&"surface_hover"), _c(&"surface_hover"), _s(3), _s(2)))
	_style(&"MenuBar", &"pressed", _box(_c(&"surface_pressed"), _c(&"surface_pressed"), _s(3), _s(2)))
	_colors(&"MenuBar", [&"font_color", &"font_hover_color", &"font_focus_color", &"font_pressed_color", &"font_hover_pressed_color"], _c(&"content"))
	_color(&"MenuBar", &"font_disabled_color", _c(&"content_disabled"))
	_type(&"MenuBar", &"label")

func _fields() -> void:
	for type: StringName in [&"LineEdit", &"TextEdit"]:
		_style(type, &"normal", _box(_c(&"surface_sunken"), _c(&"border"), _s(3), _s(2)))
		_style(type, &"focus", _focus())
		_style(type, &"read_only", _box(_faded(_c(&"surface_sunken")), _c(&"divider"), _s(3), _s(2)))
		_color(type, &"font_color", _c(&"content"))
		_color(type, &"font_selected_color", _c(&"content"))
		_color(type, &"font_placeholder_color", _c(&"content_muted"))
		_color(type, &"selection_color", _c(&"accent_subtle"))
		_color(type, &"caret_color", _c(&"content"))
	_color(&"LineEdit", &"font_uneditable_color", _c(&"content_muted"))
	_color(&"LineEdit", &"clear_button_color", _c(&"content_muted"))
	_color(&"LineEdit", &"clear_button_color_pressed", _c(&"content"))
	_color(&"TextEdit", &"font_readonly_color", _c(&"content_muted"))
	_color(&"TextEdit", &"background_color", _clear(_c(&"surface_sunken")))
	_color(&"TextEdit", &"current_line_color", _clear(_c(&"surface_hover")))
	_color(&"TextEdit", &"word_highlighted_color", _c(&"surface_hover"))
	_color(&"TextEdit", &"search_result_color", _c(&"accent_subtle"))
	_color(&"TextEdit", &"search_result_border_color", _c(&"accent"))
	_constant(&"TextEdit", &"line_spacing", _k(&"line_spacing_body"))
	_colors(&"SpinBox", [&"up_icon_modulate", &"down_icon_modulate"], _c(&"content_muted"))
	_colors(&"SpinBox", [&"up_hover_icon_modulate", &"down_hover_icon_modulate"], _c(&"content"))
	_colors(&"SpinBox", [&"up_pressed_icon_modulate", &"down_pressed_icon_modulate"], _c(&"accent"))
	_colors(&"SpinBox", [&"up_disabled_icon_modulate", &"down_disabled_icon_modulate"], _c(&"content_disabled"))
	_constant(&"SpinBox", &"buttons_width", _k(&"icon_medium"))

func _surfaces() -> void:
	_style(&"PanelContainer", &"panel", _surface(&"surface", _s(4)))
	_style(&"Panel", &"panel", _surface(&"surface"))
	_style(&"PopupPanel", &"panel", _box(_c(&"surface_raised"), _c(&"border"), _s(3), _s(3)))
	_style(&"AcceptDialog", &"panel", _box(_c(&"surface"), _c(&"surface"), _s(4), _s(4), 0, 0))
	_constant(&"AcceptDialog", &"buttons_separation", _s(3))
	# The frame of an embedded Window reaches up around its title bar.
	var title_height := _s(6) + _s(1)
	for item: StringName in [&"embedded_border", &"embedded_unfocused_border"]:
		var frame := _box(_c(&"surface"), _c(&"border_strong" if item == &"embedded_border" else &"border"), 0, 0, _k(&"radius_medium"))
		frame.expand_margin_left = _s(2)
		frame.expand_margin_right = _s(2)
		frame.expand_margin_bottom = _s(2)
		frame.expand_margin_top = title_height
		_style(&"Window", item, _lifted(frame, &"elevation_3") if item == &"embedded_border" else frame)
	_constant(&"Window", &"title_height", title_height)
	_color(&"Window", &"title_color", _c(&"content_heading"))
	_type(&"Window", &"label", &"title_font", &"title_font_size")
	_style(&"HSeparator", &"separator", _line(_c(&"divider")))
	_style(&"VSeparator", &"separator", _line(_c(&"divider"), true))
	_style(&"ScrollContainer", &"focus", _focus())
	_style(&"FoldableContainer", &"panel", _pad(_sides(_box(_c(&"surface"), _c(&"border")), true, false, true, true), _s(3), _s(3)))
	_style(&"FoldableContainer", &"title_panel", _sides(_box(_c(&"surface_raised"), _c(&"border"), _s(3), _s(2)), true, true, true, false))
	_style(&"FoldableContainer", &"title_hover_panel", _sides(_box(_c(&"surface_hover"), _c(&"border_strong"), _s(3), _s(2)), true, true, true, false))
	_style(&"FoldableContainer", &"title_collapsed_panel", _box(_c(&"surface_raised"), _c(&"border"), _s(3), _s(2)))
	_style(&"FoldableContainer", &"title_collapsed_hover_panel", _box(_c(&"surface_hover"), _c(&"border_strong"), _s(3), _s(2)))
	_style(&"FoldableContainer", &"focus", _focus())
	_colors(&"FoldableContainer", [&"font_color", &"hover_font_color", &"collapsed_font_color"], _c(&"content"))
	_type(&"FoldableContainer", &"label")
	_constant(&"FoldableContainer", &"h_separation", _s(2))

func _lists() -> void:
	_style(&"PopupMenu", &"panel", _box(_c(&"surface_raised"), _c(&"border"), _s(1), _s(1)))
	_style(&"PopupMenu", &"hover", _box(_c(&"surface_hover"), _c(&"surface_hover")))
	_style(&"PopupMenu", &"separator", _line(_c(&"divider")))
	_styles(&"PopupMenu", [&"labeled_separator_left", &"labeled_separator_right"], _line(_c(&"divider")))
	_colors(&"PopupMenu", [&"font_color", &"font_hover_color"], _c(&"content"))
	_colors(&"PopupMenu", [&"font_accelerator_color", &"font_separator_color"], _c(&"content_muted"))
	_color(&"PopupMenu", &"font_disabled_color", _c(&"content_disabled"))
	_type(&"PopupMenu", &"label")
	_type(&"PopupMenu", &"meta", &"font_separator", &"font_separator_size")
	_constant(&"PopupMenu", &"h_separation", _s(2))
	_constant(&"PopupMenu", &"v_separation", _s(2))
	_constant(&"PopupMenu", &"item_start_padding", _s(3))
	_constant(&"PopupMenu", &"item_end_padding", _s(3))
	for type: StringName in [&"TabBar", &"TabContainer"]:
		_style(type, &"tab_unselected", _rule(_clear(_c(&"surface_hover")), _s(4), _s(2)))
		_style(type, &"tab_hovered", _rule(_c(&"surface_hover"), _s(4), _s(2)))
		_style(type, &"tab_selected", _selected_tab(_s(4), _s(2)))
		_style(type, &"tab_disabled", _rule(_clear(_c(&"surface_hover")), _s(4), _s(2)))
		_style(type, &"tab_focus", _focus())
		_colors(type, [&"font_unselected_color", &"icon_unselected_color"], _c(&"content_muted"))
		_colors(type, [&"font_hovered_color", &"icon_hovered_color"], _c(&"content"))
		_colors(type, [&"font_selected_color", &"icon_selected_color"], _c(&"content_heading"))
		_colors(type, [&"font_disabled_color", &"icon_disabled_color"], _c(&"content_disabled"))
		_color(type, &"drop_mark_color", _c(&"accent"))
		_type(type, &"label")
	_style(&"TabContainer", &"panel", _box(_c(&"surface"), _c(&"border"), _s(4), _s(4), 0))
	_style(&"TabContainer", &"tabbar_background", _rule(_c(&"surface")))
	for type: StringName in [&"ItemList", &"Tree"]:
		_style(type, &"panel", _box(_c(&"surface_sunken"), _c(&"border"), _s(1), _s(1)))
		_style(type, &"focus", _focus())
		_style(type, &"hovered", _box(_c(&"surface_hover"), _c(&"surface_hover")))
		_styles(type, [&"selected", &"selected_focus"], _box(_c(&"accent_subtle"), _c(&"accent_subtle")))
		_styles(type, [&"hovered_selected", &"hovered_selected_focus"], _box(_c(&"accent_subtle"), _c(&"accent")))
		_style(type, &"cursor", _focus())
		_style(type, &"cursor_unfocused", _box(_clear(_c(&"border")), _c(&"border")))
		_colors(type, [&"font_color", &"font_hovered_color", &"font_selected_color", &"font_hovered_selected_color"], _c(&"content"))
		_color(type, &"guide_color", _c(&"divider"))
		_constant(type, &"h_separation", _s(2))
		_constant(type, &"v_separation", _s(2))
	_style(&"Tree", &"hovered_dimmed", _box(_faded(_c(&"surface_hover")), _faded(_c(&"surface_hover"))))
	_styles(&"Tree", [&"title_button_normal", &"title_button_hover", &"title_button_pressed"], _rule(_c(&"surface_raised"), _s(2), _s(1)))
	_color(&"Tree", &"title_button_color", _c(&"content_heading"))
	_color(&"Tree", &"font_disabled_color", _c(&"content_disabled"))
	_colors(&"Tree", [&"relationship_line_color", &"parent_hl_line_color", &"children_hl_line_color"], _c(&"divider"))
	_colors(&"Tree", [&"drop_position_color", &"drop_on_item_color"], _c(&"accent"))
	_colors(&"FileDialog", [&"folder_icon_color", &"file_icon_color"], _c(&"content"))
	_color(&"FileDialog", &"file_disabled_color", _c(&"content_disabled"))

func _ranges() -> void:
	var thumb := _k(&"radius_full")
	for type: StringName in [&"HScrollBar", &"VScrollBar"]:
		_styles(type, [&"scroll", &"scroll_focus"], _pad(_box(_c(&"surface_sunken"), _c(&"surface_sunken"), 0, 0, thumb, 0), _s(1), _s(1)))
		_style(type, &"grabber", _box(_c(&"border"), _c(&"border"), 0, 0, thumb, 0))
		_style(type, &"grabber_highlight", _box(_c(&"border_strong"), _c(&"border_strong"), 0, 0, thumb, 0))
		_style(type, &"grabber_pressed", _box(_c(&"accent"), _c(&"accent"), 0, 0, thumb, 0))
	for type: StringName in [&"HSlider", &"VSlider"]:
		var half := _s(1) / 2
		_style(type, &"slider", _pad(_box(_c(&"surface_sunken"), _c(&"border"), 0, 0, thumb), half, half))
		_style(type, &"grabber_area", _pad(_box(_c(&"accent"), _c(&"accent"), 0, 0, thumb, 0), half, half))
		_style(type, &"grabber_area_highlight", _pad(_box(_c(&"accent_hover"), _c(&"accent_hover"), 0, 0, thumb, 0), half, half))
	_style(&"ProgressBar", &"background", _box(_c(&"surface_sunken"), _c(&"border"), 0, _s(1)))
	_style(&"ProgressBar", &"fill", _box(_c(&"accent"), _c(&"accent"), 0, _s(1), -1, 0))
	# The value crosses the fill and the track, so an outline keeps it readable on both.
	_color(&"ProgressBar", &"font_color", _c(&"content"))
	_color(&"ProgressBar", &"font_outline_color", _c(&"surface_sunken"))
	_constant(&"ProgressBar", &"outline_size", _s(1))
	_type(&"ProgressBar", &"meta")

# Kit type variations.

func _kit_text() -> void:
	_label(&"RookframeTitle", &"display", &"content_heading")
	_label(&"RookframeSubtitle", &"title", &"content_heading")
	_label(&"RookframeHeading", &"heading", &"content_heading")
	_label(&"RookframeIdentity", &"heading", &"content_heading")
	_label(&"RookframeBody", &"body", &"content")
	_label(&"RookframeLabel", &"label", &"content")
	_label(&"RookframeValue", &"value", &"content")
	_label(&"RookframeMeta", &"meta", &"content_muted")
	_label(&"RookframeStatus", &"meta", &"content_muted")
	_label(&"RookframePending", &"meta", &"content_muted")
	_label(&"RookframeBadgeText", &"meta", &"content_muted")
	_label(&"RookframeSuccess", &"meta", &"success")
	_label(&"RookframeError", &"meta", &"danger")
	_label(&"RookframeDialogTitle", &"title", &"content_heading")
	_label(&"RookframeDialogCopy", &"body", &"content")
	_label(&"RookframeInlineNoticeTitle", &"title", &"content_heading")
	_label(&"RookframeInlineNoticeBody", &"body", &"content_muted")
	_label(&"RookframeInlineNoticeState", &"meta", &"content")
	_label(&"RookframeArcCaptionKicker", &"meta", &"content_muted")
	_label(&"RookframeArcCaptionTitle", &"heading", &"content_heading")
	_label(&"RookframeCreatureClassificationTablet", &"meta", &"content_muted")
	_label(&"RookframeCreatureDialogAmountDesktop", &"label", &"content")

func _kit_actions() -> void:
	var pill := _k(&"radius_full")
	for type: StringName in [&"RookframeSecondaryButton", &"RookframeShellControl", &"RookframeManagedControl", &"RookframeManagedAffirm", &"RookframeActionRoll", &"RookframeCompactAction", &"WizardButton", &"WizardSection", &"TaskSection"]:
		_vary(type, &"Button")
	_secondary(&"RookframeSecondaryButton", _s(4), _s(2))
	for type: StringName in [&"RookframeShellControl", &"RookframeManagedControl", &"RookframeManagedAffirm"]:
		_secondary(type, _s(3), _s(3))
	_secondary(&"RookframeActionRoll", _s(3), _s(2))
	_secondary(&"RookframeCompactAction", _s(4), _s(1))
	_type(&"RookframeCompactAction", &"meta")
	_vary(&"RookframeCompactActionTouch", &"RookframeCompactAction")
	_secondary(&"RookframeCompactActionTouch", _s(4), _s(2))
	_secondary(&"WizardButton", _s(4), _s(2))
	for type: StringName in [&"WizardSection", &"TaskSection"]:
		# A section switch keeps its frame and takes the accent while current.
		_secondary(type, _s(4), _s(2))
		_styles(type, [&"pressed", &"hover_pressed"], _box(_c(&"accent_subtle"), _c(&"accent"), _s(4), _s(2)))
	_vary(&"TaskButton", &"Button")
	for type: StringName in [&"RookframePrimaryButton", &"RookframeGoldButton", &"TaskPrimary", &"WizardPrimary"]:
		_vary(type, &"Button")
		_primary(type, _s(4), _s(2))
	for type: StringName in [&"RookframeManagedCommit", &"RookframeManagedSelected"]:
		_vary(type, &"Button")
		_primary(type, _s(3), _s(3))
	for type: StringName in [&"RookframeQuietButton", &"TaskQuiet", &"WizardQuiet"]:
		_vary(type, &"Button")
		_quiet(type, _s(3), _s(2))
	_vary(&"RookframeDangerButton", &"Button")
	_destructive(&"RookframeDangerButton", _s(4), _s(2))
	_vary(&"RookframeDangerOutline", &"Button")
	_destructive(&"RookframeDangerOutline", _s(3), _s(2), true)
	# Icon-only actions carry no padding: the caller's minimum size frames the icon.
	for type: StringName in [&"RookframeIcon", &"RookframeActionIcon"]:
		_vary(type, &"Button")
		_quiet(type, 0, 0)
		_constant(type, &"icon_max_width", _k(&"icon_medium"))
	_inks(&"RookframeIcon", [_c(&"content_muted"), _c(&"content"), _c(&"accent")])
	_inks(&"RookframeActionIcon", [_c(&"content_muted"), _c(&"content"), _c(&"accent")])
	_vary(&"RookframePrimaryIcon", &"Button")
	_primary(&"RookframePrimaryIcon", 0, 0)
	_constant(&"RookframePrimaryIcon", &"icon_max_width", _k(&"icon_medium"))
	_vary(&"RookframeCircularAction", &"Button")
	_secondary(&"RookframeCircularAction", 0, 0, pill)
	_constant(&"RookframeCircularAction", &"icon_max_width", _k(&"icon_medium"))
	_vary(&"TaskGlyphButton", &"Button")
	_secondary(&"TaskGlyphButton", _s(1), _s(1) / 2)
	_type(&"TaskGlyphButton", &"meta")
	for type: StringName in [&"RookframeTabButton", &"TaskDetailTab"]:
		_vary(type, &"Button")
		_tab(type, _s(4), _s(2))
	_vary(&"RookframeChoiceRow", &"Button")
	_row(&"RookframeChoiceRow", _s(4), _s(3))
	for type: StringName in [&"TaskChoice", &"WizardChoice"]:
		_vary(type, &"Button")
		_row(type, 0, 0)
	_vary(&"RookframeActionSelect", &"OptionButton")
	_vary(&"RookframeActionTextField", &"LineEdit")
	_vary(&"RookframeSearchInput", &"LineEdit")
	_styles(&"RookframeSearchInput", [&"normal", &"focus", &"read_only"], _empty())
	# A favorite mark is its own target: no row frame around it.
	_vary(&"RookframeFavorite", &"CheckBox")
	_styles(&"RookframeFavorite", BUTTON_STATES, _empty(_s(2), _s(2)))
	_style(&"RookframeFavorite", &"focus", _focus())
	_color(&"RookframeFavorite", &"checkbox_unchecked_color", _c(&"content_muted"))
	_color(&"RookframeFavorite", &"checkbox_checked_color", _c(&"favorite"))
	# The shared Button composes one name from emphasis, layout and density.
	var bases := {&"components_button": &"RookframeSecondaryButton", &"components_button_primary": &"RookframePrimaryButton",
		&"components_button_destructive": &"RookframeDangerButton", &"components_button_emblem": &"RookframePrimaryButton"}
	for type: StringName in bases:
		var stacked := StringName(type + "__stacked")
		_vary(type, bases[type])
		_vary(StringName(type + "__compact"), type)
		_vary(stacked, type)
		_vary(StringName(stacked + "__compact"), stacked)
		_constant(type, &"minimum_height", _k(&"action_height"))
		_constant(StringName(type + "__compact"), &"minimum_height", _k(&"target_minimum"))
		_constant(stacked, &"icon_max_width", _k(&"icon_large"))
		_theme.set_font_size(&"font_size", stacked, _tokens.get_font_size(&"meta", Tokens.TYPE))
		_constant(StringName(stacked + "__compact"), &"minimum_height", _k(&"target_minimum"))
		_constant(StringName(stacked + "__compact"), &"icon_max_width", _k(&"icon_medium"))

func _kit_surfaces() -> void:
	_panel(&"RookframeSurface", _surface(&"surface", _s(4)))
	_panel(&"RookframeRaisedSurface", _lifted(_surface(&"surface_raised", _s(4)), &"elevation_1"))
	_panel(&"RookframeInsetSurface", _surface(&"surface_sunken", _s(3)))
	_panel(&"RookframeActiveSurface", _surface(&"surface_pressed", 0, &"border_strong"))
	_panel(&"RookframeCanvas", _box(_c(&"canvas"), _c(&"canvas"), 0, 0, 0, 0))
	_panel(&"RookframeSection", _rule(_clear(_c(&"surface")), _s(4), _s(4)))
	_panel(&"RookframeSubtleFrame", _rule(_clear(_c(&"surface"))))
	_panel(&"RookframeRaisedFrame", _surface(&"surface_raised"))
	_panel(&"RookframeInsetFrame", _surface(&"surface_sunken"))
	_panel(&"RookframePackageFrame", _surface(&"surface_sunken"))
	_panel(&"RookframePackageInk", _box(_c(&"surface_sunken"), _c(&"surface_sunken"), 0, 0, 0, 0))
	_panel(&"RookframeShellRail", _surface(&"surface"))
	_panel(&"RookframeManagedChrome", _rule(_c(&"surface_raised"), _s(4), _s(2)))
	_panel(&"RookframeManagedChromeCompact", _rule(_c(&"surface_raised"), _s(3), _s(2)))
	var modal := _k(&"radius_large")
	for type: StringName in [&"RookframeGoldFrame", &"RookframeTaskFrame"]:
		_panel(type, _lifted(_box(_c(&"surface"), _c(&"border_strong"), 0, 0, modal), &"elevation_3"))
	# A modal pads its own content, so the dialog parts inside it add only vertical rhythm.
	for type: StringName in [&"RookframeModalSurface", &"RookframeDialogSurface", &"RookframeManagedSurface"]:
		_panel(type, _lifted(_box(_c(&"surface"), _c(&"border_strong"), _s(5), _s(5), modal), &"elevation_3"))
	var dialog_message := _empty(0, _s(4))
	dialog_message.content_margin_top = _s(3)
	_panel(&"RookframeDialogMessage", dialog_message)
	var dialog_body := _empty(0, _s(4))
	dialog_body.content_margin_top = 0
	_panel(&"RookframeDialogBody", dialog_body)
	var dialog_footer := _sides(_box(_clear(_c(&"surface")), _c(&"divider"), 0, _s(4)), false, true, false, false)
	dialog_footer.content_margin_bottom = 0
	_panel(&"RookframeDialogFooter", dialog_footer)
	_panel(&"RookframeBadge", _box(_c(&"surface_raised"), _c(&"border"), _s(2), _s(1)))
	_panel(&"RookframeGoldBadge", _box(_c(&"accent_subtle"), _c(&"accent"), _s(2), _s(1)))
	_panel(&"RookframeNotice", _surface(&"surface_raised", _s(3)))
	_panel(&"RookframeInlineNotice", _surface(&"surface_sunken", _s(4)))
	var states := {"Info": "info", "Success": "success", "Pending": "warning", "Error": "danger"}
	for state: String in states:
		_status(StringName("RookframeNotice" + state), states[state], _s(3))
		_status(StringName("RookframeInlineNotice" + state), states[state], _s(4))
	var step := _k(&"radius_full")
	var strong := _k(&"border_width_strong")
	_panel(&"RookframeStepPending", _box(_c(&"surface"), _c(&"border"), 0, 0, step, strong))
	_panel(&"RookframeStepCurrent", _box(_c(&"accent"), _c(&"accent"), 0, 0, step, strong))
	_panel(&"RookframeStepComplete", _box(_c(&"surface_raised"), _c(&"border_strong"), 0, 0, step, strong))
	_panel(&"RookframeStructuredRow", _rule(_clear(_c(&"surface")), _s(4), _s(3)))
	var selected_row := _box(_c(&"accent_subtle"), _c(&"accent"), _s(4), _s(3))
	_panel(&"RookframeStructuredRowSelected", _sides(selected_row, true, false, false, false, strong))
	_panel(&"RookframeSearchField", _box(_c(&"surface_sunken"), _c(&"border"), _s(3), 0))
	_panel(&"RookframeSearchFieldFocus", _box(_c(&"surface_sunken"), _c(&"focus_ring"), _s(3), 0, -1, _k(&"focus_width")))
	_panel(&"RookframePopover", _box(_c(&"surface_raised"), _c(&"border"), _s(3), _s(3), _k(&"radius_medium")), &"PopupPanel")
	# Each Action Panel leaf is its own framed sheet.
	var action_header := _box(_c(&"surface_raised"), _c(&"border"), _s(4), _s(3))
	# The emblem leaf lies over the leading edge of the header; clear it.
	action_header.content_margin_left = _k(&"action_height") + _s(6) + _s(2)
	_panel(&"RookframeActionHeader", action_header)
	_panel(&"RookframeActionSection", _box(_c(&"surface"), _c(&"border"), _s(4), _s(2)))
	_panel(&"RookframeActionFooter", _box(_c(&"surface_raised"), _c(&"border"), _s(4), _s(2)))
	_panel(&"RookframeActionEmblem", _box(_c(&"surface_sunken"), _c(&"ornament"), _s(3), _s(2)))
	_vary(&"RookframeActionDivider", &"HSeparator")
	_style(&"RookframeActionDivider", &"separator", _line(_c(&"ornament")))

func _kit_tabletop() -> void:
	var pill := _k(&"radius_full")
	_panel(&"RookframeHudBar", _lifted(_box(_c(&"surface_raised"), _c(&"border"), _s(4), _s(4), _k(&"radius_medium")), &"elevation_2"))
	_panel(&"RookframeHudBar__medium", _lifted(_box(_c(&"surface_raised"), _c(&"border"), _s(3), _s(3), _k(&"radius_medium")), &"elevation_2"), &"RookframeHudBar")
	_panel(&"RookframeHudBar__compact", _lifted(_box(_c(&"surface_raised"), _c(&"border"), _s(2), _s(2), _k(&"radius_medium")), &"elevation_2"), &"RookframeHudBar")
	_panel(&"RookframeHudAttached", _box(_c(&"surface"), _c(&"border"), _s(4), _s(4), _k(&"radius_medium")))
	_panel(&"RookframeHudAttached__medium", _box(_c(&"surface"), _c(&"border"), _s(4), _s(4), _k(&"radius_medium")), &"RookframeHudAttached")
	_panel(&"RookframeHudAttached__compact", _box(_c(&"surface"), _c(&"border"), _s(2), _s(2), _k(&"radius_medium")), &"RookframeHudAttached")
	_constant(&"RookframeHudBar", &"separation", _s(3))
	_constant(&"RookframeHudBar__medium", &"separation", _s(2))
	_constant(&"RookframeHudBar__compact", &"separation", _s(2))
	_vary(&"RookframeHud", &"VBoxContainer")
	_vary(&"RookframeHudIdentity", &"Button")
	_quiet(&"RookframeHudIdentity", _s(3), _s(2))
	_vary(&"RookframeHudIdentity__compact", &"RookframeHudIdentity")
	_quiet(&"RookframeHudIdentity__compact", _s(2), _s(1))
	_vary(&"RookframeHudRule", &"VSeparator")
	_style(&"RookframeHudRule", &"separator", _line(_c(&"divider"), true))
	_constant(&"RookframeHudRule", &"separation", _s(3))
	_vary(&"RookframeVital", &"ProgressBar")
	_style(&"RookframeVital", &"background", _box(_c(&"surface_sunken"), _c(&"border"), 0, _s(1)))
	var vitals := {&"RookframeVital": &"vital_full", &"RookframeVitalWounded": &"vital_wounded",
		&"RookframeVitalCritical": &"vital_critical", &"RookframeVitalDepleted": &"vital_depleted"}
	for type: StringName in vitals:
		if type != &"RookframeVital":
			_vary(type, &"RookframeVital")
		_style(type, &"fill", _box(_c(vitals[type]), _c(vitals[type]), 0, _s(1), -1, 0))
	# Arc Picker: round entries on a rail, with a caption plate.
	for type: StringName in [&"RookframeArcCategory", &"RookframeArcItem"]:
		_vary(type, &"Button")
		_secondary(type, 0, 0, pill)
		_styles(type, [&"pressed", &"hover_pressed"], _box(_c(&"accent_subtle"), _c(&"accent"), 0, 0, pill, _k(&"border_width_strong")))
	_constant(&"RookframeArcCategory", &"icon_max_width", _k(&"icon_large"))
	_panel(&"RookframeArcWell", _box(_c(&"surface_sunken"), _c(&"surface_sunken"), 0, 0, pill, 0), &"Panel")
	_panel(&"RookframeArcCaption", _lifted(_box(_c(&"surface_raised"), _c(&"border"), _s(3), _s(1)), &"elevation_1"))
	_vary(&"RookframeArcTrack", &"Container")
	_color(&"RookframeArcTrack", &"rail_color", _c(&"border"))
	_color(&"RookframeArcTrack", &"rail_active_color", _c(&"accent"))
	_color(&"RookframeArcTrack", &"rail_core_color", _c(&"surface_sunken"))

func _kit_tasks() -> void:
	var divider := _c(&"divider")
	var none := _clear(_c(&"surface"))
	_panel(&"TaskAttribute", _box(_c(&"surface"), divider, _s(3), _s(3)))
	_panel(&"TaskAttributeTablet", _box(_c(&"surface"), divider, _s(2), _s(2)))
	_panel(&"TaskAttributeCompact", _box(_c(&"surface"), divider, _s(1), _s(1)))
	_panel(&"TaskDetail", _box(_c(&"surface"), divider, _s(6), _s(6)))
	_panel(&"TaskDetailPanel", _box(_c(&"surface"), divider, _s(6), _s(6)), &"Panel")
	_panel(&"TaskFacts", _sides(_box(_c(&"surface"), divider, 0, _s(4)), false, true, false, true))
	_panel(&"TaskFactsTablet", _sides(_box(_c(&"surface"), divider, 0, _s(3)), false, true, false, true))
	_panel(&"TaskFactsCompact", _sides(_box(_c(&"surface"), divider, 0, _s(2)), false, true, false, true))
	for type: StringName in [&"TaskFooter", &"TaskFooterPhone"]:
		_panel(type, _sides(_box(_c(&"surface"), _c(&"border")), false, true, false, false))
	var strong := _k(&"border_width_strong")
	_panel(&"TaskResult", _sides(_box(_c(&"surface_raised"), _c(&"accent"), _s(4), _s(3)), true, false, false, false, strong))
	_panel(&"TaskResultCompact", _sides(_box(_c(&"surface_raised"), _c(&"accent"), _s(3), _s(2)), true, false, false, false, strong))
	_panel(&"WizardAttribute", _rule(none, 0, _s(2)))
	_panel(&"WizardAttributeCompact", _rule(none))
	_panel(&"WizardDivider", _sides(_box(none, divider), true, false, false, false), &"Panel")
	_panel(&"WizardFacts", _sides(_box(none, divider, 0, _s(4)), false, true, false, true))
	_panel(&"WizardFactsTablet", _sides(_box(none, divider, 0, _s(2)), false, true, false, true))
	_panel(&"WizardFactsCompact", _sides(_box(none, divider, 0, _s(2)), false, true, false, true))
	_panel(&"WizardFormulaBox", _rule(none, 0, _s(3)))
	_panel(&"WizardFormulaBoxTablet", _rule(none, 0, _s(2)))
	_panel(&"WizardFormulaBoxCompact", _rule(none, 0, _s(1)))
	_panel(&"WizardResult", _box(_c(&"surface_sunken"), _c(&"surface_sunken"), _s(4), _s(3), -1, 0))
	_panel(&"WizardResultCompact", _box(_c(&"surface_sunken"), _c(&"surface_sunken"), _s(3), _s(2), -1, 0))
	_panel(&"WizardLedger", _lifted(_box(_c(&"surface"), _c(&"border_strong"), 0, 0, _k(&"radius_large")), &"elevation_3"), &"Panel")
	_panel(&"WizardPane", _box(_c(&"surface_sunken"), divider), &"Panel")
	_panel(&"WizardPlain", _box(none, none, 0, 0, 0, 0), &"Panel")
	for type: StringName in [&"TaskFormula", &"WizardFormula"]:
		_vary(type, &"Label")
		_style(type, &"normal", _rule(none, 0, _s(3)))
	for type: StringName in [&"TaskFormulaCompact", &"WizardFormulaCompact"]:
		_vary(type, &"Label")
		_style(type, &"normal", _rule(none, 0, _s(1)))
