extends RefCounted
const METRICS = preload("res://rookframe/ui/theme/silkbound_line_height.gd")
static func apply(field: VBoxContainer, compact: bool, multiline: bool) -> void:
	field.add_theme_constant_override("separation",4 if compact else 8)
	field.get_node(^"Error").visible = not field.error_text.is_empty()
	field.get_node(^"Error").custom_minimum_size.y = 0
	for pair in [["Label",17 if compact else 18 if field.get_viewport_rect().size.x <= 1300 else 20],["Help",17],["Error",15 if compact else 17]]:
		var label: Label = field.get_node(pair[0])
		label.add_theme_font_size_override("font_size",pair[1])
		METRICS.apply(label,1.1 if compact and pair[0] == "Error" else 1.4)
	var editor: Control = field.get_node(^"Editor")
	editor.add_theme_font_size_override("font_size",(18 if multiline else 19) if compact else 20)
	METRICS.apply(editor,1.3)
	editor.custom_minimum_size.y = (64 if compact else 152) if multiline else 48
	for state in ["normal","focus","read_only"]:
		var frame := editor.get_theme_stylebox(state).duplicate() as StyleBoxFlat
		if frame == null:
			continue
		if state == "normal":
			frame.border_color = Color("8f999d")
		frame.content_margin_left = 12
		frame.content_margin_right = 12
		frame.content_margin_top = 8 if compact else 10
		frame.content_margin_bottom = frame.content_margin_top
		editor.add_theme_stylebox_override(state,frame)
