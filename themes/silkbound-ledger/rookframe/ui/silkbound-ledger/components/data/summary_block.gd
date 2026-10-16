@tool
extends "res://rookframe/ui/components/data/summary_block.gd"

func _fit_presentation() -> void:
	var phone := get_viewport_rect().size.y <= 560 or get_viewport_rect().size.x <= 740
	var tablet := get_viewport_rect().size.x <= 1300 and not phone
	get_node(^"Rule").color = Color("3e4346")
	add_theme_constant_override("separation", 6 if phone or tablet else 16)
	get_node(^"Content").add_theme_constant_override("separation", 4 if phone else 6 if tablet else 12)
	get_node(^"Content/Heading").add_theme_constant_override("separation", 10 if phone else 12)
	get_node(^"Content/Heading/Title").add_theme_font_override("font",preload("res://rookframe/ui/theme/silkbound_medium.tres"))
	get_node(^"Content/Heading/Title").add_theme_font_size_override("font_size",21 if phone else 22 if tablet else 24)
	get_node(^"Content/Heading/Title").add_theme_color_override("font_color",Color("e7e7dd"))
	get_node(^"Content/Heading/Icon").self_modulate = Color("d0be8e")
	get_node(^"Content/Heading/Icon").custom_minimum_size = Vector2(22,22) if phone else Vector2(26,26)
	get_node(^"Content/Copy").add_theme_font_size_override("font_size",17 if phone or tablet else 20)
	get_node(^"Content/Copy").add_theme_color_override("font_color",Color("aebabe"))
	for row in get_node(^"Content/Stats").get_children():
		row.get_node(^"Label").add_theme_font_size_override("font_size",17 if tablet else 20)
		row.get_node(^"Label").add_theme_color_override("font_color",Color("aebabe"))
		row.get_node(^"Value").add_theme_font_override("font",preload("res://rookframe/ui/theme/silkbound_medium.tres"))
		row.get_node(^"Value").add_theme_font_size_override("font_size",22 if tablet else 27)
		row.get_node(^"Value").add_theme_color_override("font_color",Color("e7e7dd"))
	for row in get_node(^"Content/Rows").get_children():
		row.get_node(^"Rule").color = Color("3e4346")
		row.get_node(^"Inset/Row/Label").custom_minimum_size.x = 0
		for edge in ["top","bottom"]:
			row.get_node(^"Inset").add_theme_constant_override("margin_"+edge,6 if phone else 2 if tablet else 8)
		for label in [^"Inset/Row/Label",^"Inset/Row/Value"]:
			row.get_node(label).add_theme_font_size_override("font_size",18 if phone or tablet else 21)
			row.get_node(label).add_theme_color_override("font_color",Color("aebabe") if label == ^"Inset/Row/Label" else Color("e7e7dd"))

	for label in [get_node(^"Content/Heading/Title"), get_node(^"Content/Copy")]:
		preload("res://rookframe/ui/theme/silkbound_line_height.gd").apply(label,1.2 if phone else 1.35 if label == get_node(^"Content/Copy") else 1.4)
	for row in get_node(^"Content/Rows").get_children():
		for path in [^"Inset/Row/Label",^"Inset/Row/Value"]:
			preload("res://rookframe/ui/theme/silkbound_line_height.gd").apply(row.get_node(path),1.15 if phone else 1.2 if tablet else 1.3)
	for row in get_node(^"Content/Stats").get_children():
		for path in [^"Label",^"Value"]:
			preload("res://rookframe/ui/theme/silkbound_line_height.gd").apply(row.get_node(path),1.2)
