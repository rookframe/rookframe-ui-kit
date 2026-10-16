@tool
extends "res://rookframe/ui/components/data/paginated_choices.gd"

@export var spaced_range := false

func _range_format() -> String:
	return "%d–%d\u2002of\u2002%d" if spaced_range else super._range_format()

func _fit_presentation() -> int:
	var phone := get_viewport_rect().size.y <= 560 or get_viewport_rect().size.x <= 740
	var tablet := get_viewport_rect().size.x <= 1300 and not phone
	theme = preload("res://rookframe/ui/theme/silkbound_theme.tres")
	var titles_only := true
	for entry in _entries:
		titles_only = titles_only and str(entry.get("subtitle", "")).is_empty()
	var height := 44 if phone else (48 if titles_only else 52) if tablet else 68
	get_node(^"Caption").custom_minimum_size.y = 22 if phone else (32 if titles_only else 36) if tablet else 44
	for path in [^"Caption/Title", ^"Caption/Count"]:
		get_node(path).add_theme_font_override("font", preload("res://rookframe/ui/theme/silkbound_regular.tres"))
		get_node(path).add_theme_font_size_override("font_size", 15 if phone else 16 if tablet else 18)
	get_node(^"Caption/Title").add_theme_color_override("font_color", Color("aebabe"))
	get_node(^"Caption/Count").add_theme_color_override("font_color", Color("d9ae94"))
	get_node(^"Pager").custom_minimum_size.y = 53
	get_node(^"Pager/Range").add_theme_font_size_override("font_size", 15 if phone else 17)
	get_node(^"Pager/Range").add_theme_color_override("font_color", Color("aebabe"))
	for key in ["Previous", "Next"]:
		var action := get_node("Pager/" + key) as Button
		action.theme_type_variation = "WizardButton"
		action.text = ""
		action.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		action.icon = preload("res://rookframe/ui/icons/chevron-left.svg") if key == "Previous" else preload("res://rookframe/ui/icons/chevron-right.svg")
		action.expand_icon = true
		action.accessibility_name = "Previous page" if key == "Previous" else "Next page"
		action.tooltip_text = action.accessibility_name
		for state in ["normal", "hover", "pressed", "disabled"]:
			var box := action.get_theme_stylebox(state).duplicate() as StyleBoxFlat
			box.content_margin_left = 0
			box.content_margin_right = 0
			action.add_theme_stylebox_override(state, box)
	for index in _rows.size():
		var row := _rows[index]
		var foreground := Color("e7e7dd")
		row.theme_type_variation = "WizardChoice"
		row.custom_minimum_size.y = height
		row.get_node(^"Inset/Row/Icon").self_modulate = Color("d0be8e")
		row.get_node(^"Inset/Row/Icon").custom_minimum_size = Vector2(24,24) if phone or tablet else Vector2(28,28)
		for label in [^"Inset/Row/Copy/Title", ^"Inset/Row/Value"]:
			row.get_node(label).add_theme_font_override("font", preload("res://rookframe/ui/theme/silkbound_medium.tres"))
			row.get_node(label).add_theme_color_override("font_color", foreground)
		row.get_node(^"Inset/Row/Copy/Title").add_theme_font_size_override("font_size", 19 if phone else 20 if tablet else 24)
		row.get_node(^"Inset/Row/Copy/Subtitle").add_theme_font_size_override("font_size", 14 if phone else 15 if tablet else 18)
		row.get_node(^"Inset/Row/Copy/Subtitle").add_theme_color_override("font_color", Color("aebabe"))
		row.get_node(^"Inset/Row/Copy").add_theme_constant_override("separation", 2 if phone or tablet else 4)
		row.get_node(^"Inset/Row").add_theme_constant_override("separation", 8 if phone or tablet else 12)
		var pending := bool(_entries[index].get("pending", false))
		var value := row.get_node(^"Inset/Row/Value") as Label
		value.add_theme_font_size_override("font_size", (15 if phone else 16 if tablet else 18) if pending else 20 if phone or tablet else 24)
		var measured := value.get_theme_font("font").get_string_size(value.text,HORIZONTAL_ALIGNMENT_LEFT,-1,value.get_theme_font_size("font_size")).x
		value.custom_minimum_size.x = minf(ceilf(measured),size.x / columns * 0.3)
		value.size_flags_horizontal = Control.SIZE_FILL
		for edge in ["left","right","top","bottom"]:
			row.get_node(^"Inset").add_theme_constant_override("margin_"+edge,(8 if phone or tablet else 12) if edge in ["left","right"] else 2 if phone or tablet else 8)
		preload("res://rookframe/ui/theme/silkbound_line_height.gd").apply(row.get_node(^"Inset/Row/Copy/Title"),1.1 if phone else 1.15)
		preload("res://rookframe/ui/theme/silkbound_line_height.gd").apply(row.get_node(^"Inset/Row/Copy/Subtitle"),1.1 if phone else 1.2)
		preload("res://rookframe/ui/theme/silkbound_line_height.gd").apply(value,1.15)
	return height

func _draw() -> void:
	if framed_collection:
		draw_style_box(preload("res://rookframe/ui/_internal/data/collection_frame.tres"), Rect2(Vector2.ZERO, size))
		if get_node(^"Caption").visible:
			draw_style_box(preload("res://rookframe/ui/_internal/data/collection_caption.tres"), Rect2(Vector2.ZERO, Vector2(size.x, get_node(^"Caption").size.y)))
	draw_line(Vector2(0, 0.5), Vector2(size.x, 0.5), Color("3e4346"))
	var pager := get_node_or_null(^"Pager") as Control
	if pager != null and pager.visible:
		draw_line(Vector2(0, pager.position.y), Vector2(size.x, pager.position.y), Color("3e4346"))

func _arrange_rows() -> Vector3:
	var phone := get_viewport_rect().size.y <= 560
	var tablet := get_viewport_rect().size.x <= 1150 and not phone
	var height := 48 if phone else 59 if tablet and collection_layout == 1 else 55 if tablet else 65 if collection_layout == 1 else 59
	if not framed_collection:
		height = 44 if phone else 56 if tablet else 68
		if tablet:
			var titles_only := true
			for entry in _entries:
				titles_only = titles_only and str(entry.get("subtitle", "")).is_empty()
			if titles_only:
				height = 48
	var grid := get_node(^"Area/Rows") as GridContainer
	var inset := 0 if phone or not framed_collection else 5 if tablet else 8
	var vertical_inset := 8 if framed_collection and not phone else 0
	grid.offset_left = inset
	grid.offset_right = -inset
	grid.offset_top = vertical_inset
	grid.columns = columns
	grid.add_theme_constant_override("h_separation", (12 if phone or tablet else 28) if framed_collection else 8)
	grid.add_theme_constant_override("v_separation", 2 if phone and not framed_collection else 4)
	get_node(^"Caption").visible = not (framed_collection and phone)
	get_node(^"Pager/Range").visible = not (framed_collection and phone)
	get_node(^"Pager/FooterContent").visible = get_node(^"Pager/FooterContent").get_child_count() > 0
	get_node(^"Area/Empty").visible = _entries.is_empty()
	get_node(^"Area/Empty").text = empty_text
	get_node(^"Caption").custom_minimum_size.y = (32 if tablet else 39) if framed_collection else 28 if phone else 42
	get_node(^"Pager").custom_minimum_size.y = 44 if framed_collection else 48 if phone else 53
	get_node(^"Caption/Title").add_theme_font_size_override("font_size", (13 if tablet else 16) if framed_collection else 10 if phone else 12)
	get_node(^"Caption/Count").add_theme_font_size_override("font_size", (14 if tablet else 18) if framed_collection else 10 if phone else 12)
	get_node(^"Pager/Range").add_theme_font_size_override("font_size", 10 if phone and not framed_collection else 12)
	get_node(^"Pager/Indicator/Page").add_theme_font_size_override("font_size", 15 if phone else 14)
	get_node(^"Pager/Indicator/PhoneCount").visible = framed_collection and phone
	if framed_collection:
		get_node(^"Caption/Title").add_theme_color_override("font_color", Color("d9ae94"))
		for label in [^"Caption/Title", ^"Caption/Count", ^"Pager/Range"]:
			get_node(label).add_theme_stylebox_override("normal", preload("res://rookframe/ui/_internal/data/collection_label.tres"))
	for button in [^"Pager/Previous", ^"Pager/Next"]:
		get_node(button).theme_type_variation = "TaskGlyphButton" if framed_collection else "TaskButton"
		get_node(button).add_theme_font_size_override("font_size", (25 if phone else 24) if framed_collection else 12 if phone else 15)
	for row in _rows:
		row.custom_minimum_size.y = height
		var title := row.get_node(^"Inset/Row/Copy/Title") as Label
		if framed_collection:
			title.add_theme_font_override("font", preload("res://rookframe/ui/_internal/data/collection_title.tres"))
			title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			title.max_lines_visible = 2
			title.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		title.add_theme_font_size_override("font_size", (16 if phone and collection_layout == 2 else 17 if phone else 15 if tablet else 19) if framed_collection else 14 if phone and columns == 2 else 15 if phone else 16 if tablet else 20)
		row.get_node(^"Inset/Row/Copy/Subtitle").add_theme_font_size_override("font_size", (13 if phone else 12 if tablet else 14) if framed_collection else 10 if phone else 11 if tablet else 12)
		row.get_node(^"Inset/Row/Icon").custom_minimum_size = (Vector2(29, 29) if phone or tablet else Vector2(38, 38)) if framed_collection else Vector2(23, 23) if phone else Vector2(26, 26) if tablet else Vector2(30, 30)
		row.get_node(^"Inset/Row").add_theme_constant_override("separation", (8 if phone else 7 if tablet else 12) if framed_collection else 8 if phone else 10 if tablet else 14)
		for edge in ["left", "right", "top", "bottom"]:
			var horizontal: bool = edge in ["left", "right"]
			var padding := (6 if horizontal else 4) if phone else (6 if horizontal else 7) if tablet else (12 if horizontal else 10) if collection_layout == 2 else (10 if horizontal else 9)
			if not framed_collection:
				padding = (9 if horizontal else 4) if phone else (10 if horizontal else 8) if tablet else (16 if horizontal else 9)
			row.get_node(^"Inset").add_theme_constant_override("margin_" + edge, padding)
		var value := row.get_node(^"Inset/Row/Value") as Label
		value.size_flags_horizontal = Control.SIZE_FILL if framed_collection or columns > 1 or tablet else Control.SIZE_EXPAND_FILL
		if framed_collection:
			value.add_theme_font_override("font", get_theme_font("font"))
		var pending := bool(_entries[_rows.find(row)].get("pending", false))
		value.add_theme_font_size_override("font_size", 12 if pending else (18 if phone else (14 if collection_layout == 2 else 16) if tablet else 18 if collection_layout == 2 else 20) if framed_collection else 17 if tablet else 20)
		var measured := value.get_theme_font("font").get_string_size(value.text, HORIZONTAL_ALIGNMENT_LEFT, -1, value.get_theme_font_size("font_size")).x
		value.custom_minimum_size.x = minf(ceilf(measured), (size.x - inset * 2) / columns * 0.3) if framed_collection else minf(ceilf(measured), size.x * 0.3) if tablet else 14 if columns > 1 else 0

	height = _fit_presentation()
	return Vector3(height, inset, vertical_inset)

func _style_entry(row: Control, entry: Dictionary, selected_id: String) -> void:
	row.get_node(^"Inset/Row/Icon").self_modulate = Color("d0be8e") if framed_collection or str(entry.id) == selected_id else Color("aebabe")
	var pending := bool(entry.get("pending", false))
	row.get_node(^"Inset/Row/Value").add_theme_font_size_override("font_size", 12 if pending else 20)
	row.get_node(^"Inset/Row/Value").add_theme_color_override("font_color", Color("aebabe") if pending else Color("d0be8e"))
