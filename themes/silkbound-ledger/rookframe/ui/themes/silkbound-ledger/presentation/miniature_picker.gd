@tool
extends RefCounted
const Appearance = preload("res://rookframe/ui/_internal/presentation/appearance.gd")




func _arrange(control) -> void:
	if not control.is_node_ready(): return
	var phone = control.size.y <= 560
	var outer = 12 if phone else 16 if control.size.x <= 1300 else 28
	for edge in ["left", "right"]: Appearance.override_item(control.get_node("Inset"), "constants", "margin_" + edge, outer + 16)
	for edge in ["top", "bottom"]: Appearance.override_item(control.get_node("Inset"), "constants", "margin_" + edge, outer + 8)
	Appearance.override_item(control.get_node("Inset/Layout"), "constants", "separation", 20 if phone else 24)
	Appearance.write(control.get_node("Inset/Layout/Header"), ^"custom_minimum_size:y", 44 if phone else 56)
	Appearance.override_item(control.get_node(control.HEADER + "Copy/Title"), "font_sizes", "font_size", 25 if phone else 32)
	Appearance.override_item(control.get_node(control.BODY + "Note"), "font_sizes", "font_size", 13 if phone else 18)
	Appearance.write(control.get_node("Inset/Layout/Footer"), ^"custom_minimum_size:y", 48 if phone else 60)
	for path in [control.HEADER + "Close", control.FOOTER + "Cancel", control.FOOTER + "Choose"]:
		var action: Button = control.get_node(path)
		Appearance.write(action, ^"custom_minimum_size:y", 44)
		Appearance.override_item(action, "font_sizes", "font_size", 18 if phone else 20)
		for state in ["normal", "hover", "pressed", "disabled"]:
			var box = action.get_theme_stylebox(state).duplicate()
			Appearance.write(box, ^"content_margin_top", 4)
			Appearance.write(box, ^"content_margin_bottom", 4)
			Appearance.override_item(action, "styles", state, box)
	control._fit_frame.call_deferred()
