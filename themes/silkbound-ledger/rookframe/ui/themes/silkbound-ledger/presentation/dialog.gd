@tool
extends RefCounted
const Appearance = preload("res://rookframe/ui/_internal/presentation/appearance.gd")




func _style_panels(control) -> void:
	for path in [^"Shell", ^"Shell/Content/Message", ^"Shell/Content/Body", ^"Shell/Content/Footer"]:
		var panel: PanelContainer = control.get_node(path)
		var style = panel.get_theme_stylebox("panel").duplicate() as StyleBoxFlat
		if style == null: continue
		Appearance.write(style, ^"bg_color", Color.TRANSPARENT)
		Appearance.write(style, ^"border_color", Color("bc927747"))
		if path == ^"Shell": style.set_border_width_all(0)
		Appearance.override_item(panel, "styles", "panel", style)

func _draw_confirmation_underline(control) -> void:
	var button = control.get_node(^"Shell/Content/Footer/Actions/Confirm") as Button
	if control.tone != control.Tone.DANGER or button.disabled:
		return
	if button.get_draw_mode() not in [BaseButton.DRAW_HOVER, BaseButton.DRAW_PRESSED, BaseButton.DRAW_HOVER_PRESSED]:
		return
	# Native Button retains input and focus; its draw signal adds the specimen's
	# text underline for the destructive hover/pressed state.
	var font = button.get_theme_font("font")
	var font_size = button.get_theme_font_size("font_size")
	var width = font.get_string_size(button.tr(button.text), HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
	var left = floorf((button.size.x - width) * 0.5)
	var baseline = floorf((button.size.y - font.get_height(font_size)) * 0.5) + font.get_ascent(font_size)
	var y = baseline + 3.0
	button.draw_line(Vector2(left, y), Vector2(left + width, y),
		button.get_theme_color("font_hover_color"), maxf(1.0, font.get_underline_thickness(font_size)))

func _scrim_color(control) -> Color:
	return Color(0, 0, 0, 0.667)

func _style_compact_layout(control, compact: bool) -> void:
	var header = control.get_node_or_null(^"Shell/Content/Header") as MarginContainer
	if header != null:
		for side in [&"margin_left", &"margin_right", &"margin_top"]:
			Appearance.override_item(header, "constants", side, 16 if compact else 24)
	for node_name in ["Message", "Body", "Footer"]:
		var panel = control.get_node("Shell/Content/" + node_name) as PanelContainer
		var style = panel.get_theme_stylebox("panel").duplicate() as StyleBox
		Appearance.write(style, ^"content_margin_left", 16.0 if compact else 24.0)
		Appearance.write(style, ^"content_margin_right", 16.0 if compact else 24.0)
		if node_name == "Message":
			Appearance.write(style, ^"content_margin_bottom", 32.0 if compact else 40.0)
		elif node_name == "Body":
			Appearance.write(style, ^"content_margin_bottom", 16.0 if compact else 24.0)
		else:
			Appearance.write(style, ^"content_margin_top", 13.0 if compact else 17.0)
			Appearance.write(style, ^"content_margin_bottom", 12.0 if compact else 16.0)
		Appearance.override_item(panel, "styles", "panel", style)
