@tool
extends RefCounted
const Appearance = preload("res://rookframe/ui/_internal/presentation/appearance.gd")




func _fit_presentation(control) -> void:
	var phone = control.get_viewport_rect().size.y <= 560 or control.get_viewport_rect().size.x <= 740
	var tablet = control.get_viewport_rect().size.x <= 1300 and not phone
	Appearance.write(control.get_node(^"Rule"), ^"color", Color("3e4346"))
	Appearance.override_item(control, "constants", "separation", 6 if phone or tablet else 16)
	Appearance.override_item(control.get_node(^"Content"), "constants", "separation", 4 if phone else 6 if tablet else 12)
	Appearance.override_item(control.get_node(^"Content/Heading"), "constants", "separation", 10 if phone else 12)
	Appearance.override_item(control.get_node(^"Content/Heading/Title"), "fonts", "font",preload("res://rookframe/ui/theme/silkbound_medium.tres"))
	Appearance.override_item(control.get_node(^"Content/Heading/Title"), "font_sizes", "font_size",21 if phone else 22 if tablet else 24)
	Appearance.override_item(control.get_node(^"Content/Heading/Title"), "colors", "font_color",Color("e7e7dd"))
	Appearance.write(control.get_node(^"Content/Heading/Icon"), ^"self_modulate", Color("d0be8e"))
	Appearance.write(control.get_node(^"Content/Heading/Icon"), ^"custom_minimum_size", Vector2(22,22) if phone else Vector2(26,26))
	Appearance.override_item(control.get_node(^"Content/Copy"), "font_sizes", "font_size",17 if phone or tablet else 20)
	Appearance.override_item(control.get_node(^"Content/Copy"), "colors", "font_color",Color("aebabe"))
	for row in control.get_node(^"Content/Stats").get_children():
		Appearance.override_item(row.get_node(^"Label"), "font_sizes", "font_size",17 if tablet else 20)
		Appearance.override_item(row.get_node(^"Label"), "colors", "font_color",Color("aebabe"))
		Appearance.override_item(row.get_node(^"Value"), "fonts", "font",preload("res://rookframe/ui/theme/silkbound_medium.tres"))
		Appearance.override_item(row.get_node(^"Value"), "font_sizes", "font_size",22 if tablet else 27)
		Appearance.override_item(row.get_node(^"Value"), "colors", "font_color",Color("e7e7dd"))
	for row in control.get_node(^"Content/Rows").get_children():
		Appearance.write(row.get_node(^"Rule"), ^"color", Color("3e4346"))
		Appearance.write(row.get_node(^"Inset/Row/Label"), ^"custom_minimum_size:x", 0)
		for edge in ["top","bottom"]:
			Appearance.override_item(row.get_node(^"Inset"), "constants", "margin_"+edge,6 if phone else 2 if tablet else 8)
		for label in [^"Inset/Row/Label",^"Inset/Row/Value"]:
			Appearance.override_item(row.get_node(label), "font_sizes", "font_size",18 if phone or tablet else 21)
			Appearance.override_item(row.get_node(label), "colors", "font_color",Color("aebabe") if label == ^"Inset/Row/Label" else Color("e7e7dd"))

	for label in [control.get_node(^"Content/Heading/Title"), control.get_node(^"Content/Copy")]:
		preload("res://rookframe/ui/theme/silkbound_line_height.gd").apply(label,1.2 if phone else 1.35 if label == control.get_node(^"Content/Copy") else 1.4)
	for row in control.get_node(^"Content/Rows").get_children():
		for path in [^"Inset/Row/Label",^"Inset/Row/Value"]:
			preload("res://rookframe/ui/theme/silkbound_line_height.gd").apply(row.get_node(path),1.15 if phone else 1.2 if tablet else 1.3)
	for row in control.get_node(^"Content/Stats").get_children():
		for path in [^"Label",^"Value"]:
			preload("res://rookframe/ui/theme/silkbound_line_height.gd").apply(row.get_node(path),1.2)
