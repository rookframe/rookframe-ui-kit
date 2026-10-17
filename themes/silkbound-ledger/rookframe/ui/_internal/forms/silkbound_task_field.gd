extends RefCounted
const Appearance = preload("res://rookframe/ui/_internal/presentation/appearance.gd")
const METRICS = preload("res://rookframe/ui/theme/silkbound_line_height.gd")
static func apply(field: VBoxContainer, compact: bool, multiline: bool) -> void:
	Appearance.override_item(field, "constants", "separation",1 if compact else 8)
	Appearance.write(field.get_node(^"Error"), ^"visible", not field.error_text.is_empty())
	Appearance.write(field.get_node(^"Error"), ^"custom_minimum_size:y", 0)
	for pair in [["Label",14 if compact else 18 if field.get_viewport_rect().size.x <= 1300 else 20],["Help",13 if compact else 17],["Error",15 if compact else 17]]:
		var label: Label = field.get_node(pair[0])
		Appearance.override_item(label, "font_sizes", "font_size",pair[1])
		if pair[0] == "Label" and field.has_theme_constant_override("label_font_size"):
			Appearance.override_item(label, "font_sizes", "font_size", field.get_theme_constant("label_font_size"))
		METRICS.apply(label,1.15 if compact else 1.4)
	var editor: Control = field.get_node(^"Editor")
	Appearance.override_item(editor, "font_sizes", "font_size",(18 if multiline else 19) if compact else 20)
	if field.has_theme_constant_override("editor_font_size"):
		Appearance.override_item(editor, "font_sizes", "font_size", field.get_theme_constant("editor_font_size"))
	METRICS.apply(editor,1.3)
	Appearance.write(editor, ^"custom_minimum_size:y", (48 if compact else 152) if multiline else (44 if compact else 48))
	if multiline and field.has_theme_constant_override("editor_minimum_height"):
		Appearance.write(editor, ^"custom_minimum_size:y", field.get_theme_constant("editor_minimum_height"))
	for state in ["normal","focus","read_only"]:
		var frame := editor.get_theme_stylebox(state).duplicate() as StyleBoxFlat
		if frame == null:
			continue
		if state == "normal":
			Appearance.write(frame, ^"border_color", Color("bc927761"))
		Appearance.write(frame, ^"content_margin_left", 12)
		Appearance.write(frame, ^"content_margin_right", 12)
		Appearance.write(frame, ^"content_margin_top", 4 if compact else 10)
		Appearance.write(frame, ^"content_margin_bottom", frame.content_margin_top)
		Appearance.override_item(editor, "styles", state,frame)
