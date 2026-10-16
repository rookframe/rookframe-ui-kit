@tool
extends "res://rookframe/ui/components/content/silkbound_miniature_browser.gd"

func _arrange() -> void:
	if not is_node_ready(): return
	var phone := size.y <= 560
	var outer := 12 if phone else 16 if size.x <= 1300 else 28
	for edge in ["left", "right"]: get_node("Inset").add_theme_constant_override("margin_" + edge, outer + 16)
	for edge in ["top", "bottom"]: get_node("Inset").add_theme_constant_override("margin_" + edge, outer + 8)
	get_node("Inset/Layout").add_theme_constant_override("separation", 20 if phone else 24)
	get_node("Inset/Layout/Header").custom_minimum_size.y = 44 if phone else 56
	get_node(HEADER + "Copy/Title").add_theme_font_size_override("font_size", 25 if phone else 32)
	get_node(BODY + "Note").add_theme_font_size_override("font_size", 13 if phone else 18)
	get_node("Inset/Layout/Footer").custom_minimum_size.y = 48 if phone else 60
	for path in [HEADER + "Close", FOOTER + "Cancel", FOOTER + "Choose"]:
		var action: Button = get_node(path)
		action.custom_minimum_size.y = 44
		action.add_theme_font_size_override("font_size", 18 if phone else 20)
		for state in ["normal", "hover", "pressed", "disabled"]:
			var box := action.get_theme_stylebox(state).duplicate()
			box.content_margin_top = 4
			box.content_margin_bottom = 4
			action.add_theme_stylebox_override(state, box)
	_fit_frame.call_deferred()
