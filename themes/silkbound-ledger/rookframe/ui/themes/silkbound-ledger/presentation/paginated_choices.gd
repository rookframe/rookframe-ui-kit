@tool
extends RefCounted
const Appearance = preload("res://rookframe/ui/_internal/presentation/appearance.gd")





func _range_format(control) -> String:
	return "%d–%d\u2002of\u2002%d" if control.spaced_range else "%d–%d of %d"

func _fit_presentation(control) -> int:
	var phone = control.get_viewport_rect().size.y <= 560 or control.get_viewport_rect().size.x <= 740
	var tablet = control.get_viewport_rect().size.x <= 1300 and not phone
	var titles_only = true
	for entry in control._entries:
		titles_only = titles_only and str(entry.get("subtitle", "")).is_empty()
	var height = 44 if phone else (48 if titles_only else 52) if tablet else 68
	Appearance.write(control.get_node(^"Caption"), ^"custom_minimum_size:y", 22 if phone else (32 if titles_only else 36) if tablet else 44)
	for path in [^"Caption/Title", ^"Caption/Count"]:
		Appearance.override_item(control.get_node(path), "fonts", "font", preload("res://rookframe/ui/theme/silkbound_regular.tres"))
		Appearance.override_item(control.get_node(path), "font_sizes", "font_size", 15 if phone else 16 if tablet else 18)
	Appearance.override_item(control.get_node(^"Caption/Title"), "colors", "font_color", Color("aebabe"))
	Appearance.override_item(control.get_node(^"Caption/Count"), "colors", "font_color", Color("d9ae94"))
	Appearance.write(control.get_node(^"Pager"), ^"custom_minimum_size:y", 53)
	Appearance.override_item(control.get_node(^"Pager/Range"), "font_sizes", "font_size", 15 if phone else 17)
	Appearance.override_item(control.get_node(^"Pager/Range"), "colors", "font_color", Color("aebabe"))
	for key in ["Previous", "Next"]:
		var action = control.get_node("Pager/" + key) as Button
		Appearance.write(action, ^"theme_type_variation", "WizardButton")
		Appearance.write(action, ^"text", "")
		Appearance.write(action, ^"icon_alignment", HORIZONTAL_ALIGNMENT_CENTER)
		Appearance.write(action, ^"icon", preload("res://rookframe/ui/icons/chevron-left.svg") if key == "Previous" else preload("res://rookframe/ui/icons/chevron-right.svg"))
		Appearance.write(action, ^"expand_icon", true)
		Appearance.write(action, ^"accessibility_name", "Previous page" if key == "Previous" else "Next page")
		Appearance.write(action, ^"tooltip_text", action.accessibility_name)
		for state in ["normal", "hover", "pressed", "disabled"]:
			var box = action.get_theme_stylebox(state).duplicate() as StyleBoxFlat
			Appearance.write(box, ^"content_margin_left", 0)
			Appearance.write(box, ^"content_margin_right", 0)
			Appearance.override_item(action, "styles", state, box)
	for index in control._rows.size():
		var row = control._rows[index]
		var foreground = Color("e7e7dd")
		Appearance.write(row, ^"theme_type_variation", "WizardChoice")
		Appearance.write(row, ^"custom_minimum_size:y", height)
		Appearance.write(row.get_node(^"Content/Row/Icon"), ^"self_modulate", Color("d0be8e"))
		Appearance.write(row.get_node(^"Content/Row/Icon"), ^"custom_minimum_size", Vector2(24,24) if phone or tablet else Vector2(28,28))
		for label in [^"Content/Row/Copy/Title", ^"Content/Row/Value"]:
			Appearance.override_item(row.get_node(label), "fonts", "font", preload("res://rookframe/ui/theme/silkbound_medium.tres"))
			Appearance.override_item(row.get_node(label), "colors", "font_color", foreground)
		Appearance.override_item(row.get_node(^"Content/Row/Copy/Title"), "font_sizes", "font_size", 19 if phone else 20 if tablet else 24)
		Appearance.override_item(row.get_node(^"Content/Row/Copy/Description"), "font_sizes", "font_size", 14 if phone else 15 if tablet else 18)
		Appearance.override_item(row.get_node(^"Content/Row/Copy/Description"), "colors", "font_color", Color("aebabe"))
		Appearance.override_item(row.get_node(^"Content/Row/Copy"), "constants", "separation", 2 if phone or tablet else 4)
		Appearance.override_item(row.get_node(^"Content/Row"), "constants", "separation", 8 if phone or tablet else 12)
		var pending = bool(control._entries[index].get("pending", false))
		var value = row.get_node(^"Content/Row/Value") as Label
		Appearance.override_item(value, "font_sizes", "font_size", (15 if phone else 16 if tablet else 18) if pending else 20 if phone or tablet else 24)
		var measured = value.get_theme_font("font").get_string_size(value.text,HORIZONTAL_ALIGNMENT_LEFT,-1,value.get_theme_font_size("font_size")).x
		Appearance.write(value, ^"custom_minimum_size:x", minf(ceilf(measured),control.size.x / control.columns * 0.3))
		Appearance.write(value, ^"size_flags_horizontal", Control.SIZE_FILL)
		for edge in ["left","right","top","bottom"]:
			Appearance.override_item(row.get_node(^"Content"), "constants", "margin_"+edge,(8 if phone or tablet else 12) if edge in ["left","right"] else 2 if phone or tablet else 8)
		preload("res://rookframe/ui/theme/silkbound_line_height.gd").apply(row.get_node(^"Content/Row/Copy/Title"),1.1 if phone else 1.15)
		preload("res://rookframe/ui/theme/silkbound_line_height.gd").apply(row.get_node(^"Content/Row/Copy/Description"),1.1 if phone else 1.2)
		preload("res://rookframe/ui/theme/silkbound_line_height.gd").apply(value,1.15)
	return height

func _draw(control) -> void:
	if control.framed_collection:
		control.draw_style_box(preload("res://rookframe/ui/_internal/data/collection_frame.tres"), Rect2(Vector2.ZERO, control.size))
		if control.get_node(^"Caption").visible:
			control.draw_style_box(preload("res://rookframe/ui/_internal/data/collection_caption.tres"), Rect2(Vector2.ZERO, Vector2(control.size.x, control.get_node(^"Caption").size.y)))
	control.draw_line(Vector2(0, 0.5), Vector2(control.size.x, 0.5), Color("3e4346"))
	var pager = control.get_node_or_null(^"Pager") as Control
	if pager != null and pager.visible:
		control.draw_line(Vector2(0, pager.position.y), Vector2(control.size.x, pager.position.y), Color("3e4346"))

func _arrange_rows(control) -> Vector3:
	var phone = control.get_viewport_rect().size.y <= 560
	var tablet = control.get_viewport_rect().size.x <= 1150 and not phone
	var height = 48 if phone else 59 if tablet and control.collection_layout == 1 else 55 if tablet else 65 if control.collection_layout == 1 else 59
	if not control.framed_collection:
		height = 44 if phone else 56 if tablet else 68
		if tablet:
			var titles_only = true
			for entry in control._entries:
				titles_only = titles_only and str(entry.get("subtitle", "")).is_empty()
			if titles_only:
				height = 48
	var grid = control.get_node(^"Area/Rows") as GridContainer
	var inset = 0 if phone or not control.framed_collection else 5 if tablet else 8
	var vertical_inset = 8 if control.framed_collection and not phone else 0
	Appearance.write(grid, ^"offset_left", inset)
	Appearance.write(grid, ^"offset_right", -inset)
	Appearance.write(grid, ^"offset_top", vertical_inset)
	Appearance.write(grid, ^"columns", control.columns)
	Appearance.override_item(grid, "constants", "h_separation", (12 if phone or tablet else 28) if control.framed_collection else 8)
	Appearance.override_item(grid, "constants", "v_separation", 2 if phone and not control.framed_collection else 4)
	Appearance.write(control.get_node(^"Caption"), ^"visible", not (control.framed_collection and phone))
	Appearance.write(control.get_node(^"Pager/Range"), ^"visible", not (control.framed_collection and phone))
	Appearance.write(control.get_node(^"Pager/FooterContent"), ^"visible", control.get_node(^"Pager/FooterContent").get_child_count() > 0)
	Appearance.write(control.get_node(^"Area/Empty"), ^"visible", control._entries.is_empty())
	Appearance.write(control.get_node(^"Area/Empty"), ^"text", control.empty_text)
	Appearance.write(control.get_node(^"Caption"), ^"custom_minimum_size:y", (32 if tablet else 39) if control.framed_collection else 28 if phone else 42)
	Appearance.write(control.get_node(^"Pager"), ^"custom_minimum_size:y", 44 if control.framed_collection else 48 if phone else 53)
	Appearance.override_item(control.get_node(^"Caption/Title"), "font_sizes", "font_size", (13 if tablet else 16) if control.framed_collection else 10 if phone else 12)
	Appearance.override_item(control.get_node(^"Caption/Count"), "font_sizes", "font_size", (14 if tablet else 18) if control.framed_collection else 10 if phone else 12)
	Appearance.override_item(control.get_node(^"Pager/Range"), "font_sizes", "font_size", 10 if phone and not control.framed_collection else 12)
	Appearance.override_item(control.get_node(^"Pager/Indicator/Page"), "font_sizes", "font_size", 15 if phone else 14)
	Appearance.write(control.get_node(^"Pager/Indicator/PhoneCount"), ^"visible", control.framed_collection and phone)
	if control.framed_collection:
		Appearance.override_item(control.get_node(^"Caption/Title"), "colors", "font_color", Color("d9ae94"))
		for label in [^"Caption/Title", ^"Caption/Count", ^"Pager/Range"]:
			Appearance.override_item(control.get_node(label), "styles", "normal", preload("res://rookframe/ui/_internal/data/collection_label.tres"))
	for button in [^"Pager/Previous", ^"Pager/Next"]:
		Appearance.write(control.get_node(button), ^"theme_type_variation", "TaskGlyphButton" if control.framed_collection else "TaskButton")
		Appearance.override_item(control.get_node(button), "font_sizes", "font_size", (25 if phone else 24) if control.framed_collection else 12 if phone else 15)
	for row in control._rows:
		Appearance.write(row, ^"custom_minimum_size:y", height)
		var title = row.get_node(^"Content/Row/Copy/Title") as Label
		if control.framed_collection:
			Appearance.override_item(title, "fonts", "font", preload("res://rookframe/ui/_internal/data/collection_title.tres"))
			Appearance.write(title, ^"autowrap_mode", TextServer.AUTOWRAP_WORD_SMART)
			Appearance.write(title, ^"max_lines_visible", 2)
			Appearance.write(title, ^"text_overrun_behavior", TextServer.OVERRUN_TRIM_ELLIPSIS)
		Appearance.override_item(title, "font_sizes", "font_size", (16 if phone and control.collection_layout == 2 else 17 if phone else 15 if tablet else 19) if control.framed_collection else 14 if phone and control.columns == 2 else 15 if phone else 16 if tablet else 20)
		Appearance.override_item(row.get_node(^"Content/Row/Copy/Description"), "font_sizes", "font_size", (13 if phone else 12 if tablet else 14) if control.framed_collection else 10 if phone else 11 if tablet else 12)
		Appearance.write(row.get_node(^"Content/Row/Icon"), ^"custom_minimum_size", (Vector2(29, 29) if phone or tablet else Vector2(38, 38)) if control.framed_collection else Vector2(23, 23) if phone else Vector2(26, 26) if tablet else Vector2(30, 30))
		Appearance.override_item(row.get_node(^"Content/Row"), "constants", "separation", (8 if phone else 7 if tablet else 12) if control.framed_collection else 8 if phone else 10 if tablet else 14)
		for edge in ["left", "right", "top", "bottom"]:
			var horizontal: bool = edge in ["left", "right"]
			var padding = (6 if horizontal else 4) if phone else (6 if horizontal else 7) if tablet else (12 if horizontal else 10) if control.collection_layout == 2 else (10 if horizontal else 9)
			if not control.framed_collection:
				padding = (9 if horizontal else 4) if phone else (10 if horizontal else 8) if tablet else (16 if horizontal else 9)
			Appearance.override_item(row.get_node(^"Content"), "constants", "margin_" + edge, padding)
		var value = row.get_node(^"Content/Row/Value") as Label
		Appearance.write(value, ^"size_flags_horizontal", Control.SIZE_FILL if control.framed_collection or control.columns > 1 or tablet else Control.SIZE_EXPAND_FILL)
		if control.framed_collection:
			Appearance.override_item(value, "fonts", "font", control.get_theme_font("font"))
		var pending = bool(control._entries[control._rows.find(row)].get("pending", false))
		Appearance.override_item(value, "font_sizes", "font_size", 12 if pending else (18 if phone else (14 if control.collection_layout == 2 else 16) if tablet else 18 if control.collection_layout == 2 else 20) if control.framed_collection else 17 if tablet else 20)
		var measured = value.get_theme_font("font").get_string_size(value.text, HORIZONTAL_ALIGNMENT_LEFT, -1, value.get_theme_font_size("font_size")).x
		Appearance.write(value, ^"custom_minimum_size:x", minf(ceilf(measured), (control.size.x - inset * 2) / control.columns * 0.3) if control.framed_collection else minf(ceilf(measured), control.size.x * 0.3) if tablet else 14 if control.columns > 1 else 0)

	height = _fit_presentation(control)
	return Vector3(height, inset, vertical_inset)

func _style_entry(control, row: Control, entry: Dictionary, selected_id: String) -> void:
	Appearance.write(row.get_node(^"Content/Row/Icon"), ^"self_modulate", Color("d0be8e") if control.framed_collection or str(entry.id) == selected_id else Color("aebabe"))
	var pending = bool(entry.get("pending", false))
	Appearance.override_item(row.get_node(^"Content/Row/Value"), "font_sizes", "font_size", 12 if pending else 20)
	Appearance.override_item(row.get_node(^"Content/Row/Value"), "colors", "font_color", Color("aebabe") if pending else Color("d0be8e"))
