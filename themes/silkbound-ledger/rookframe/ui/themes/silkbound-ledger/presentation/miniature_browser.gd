@tool
extends RefCounted
const Appearance = preload("res://rookframe/ui/_internal/presentation/appearance.gd")
const Tokens = preload("res://rookframe/ui/theme/silkbound_tokens.gd")




func _style_row(control, row: Button) -> void:
	for state in ["normal", "hover", "pressed", "hover_pressed", "disabled"]:
		var box = StyleBoxFlat.new()
		Appearance.write(box, ^"bg_color", Color(Tokens.color(&"ornament"), 0.15) if state in ["pressed", "hover_pressed"] else Color("080b0a66"))
		box.set_border_width_all(1)
		Appearance.write(box, ^"border_color", Tokens.color(&"ornament") if state in ["pressed", "hover_pressed"] else Color(Tokens.color(&"ornament"), 0.28))
		Appearance.override_item(row, "styles", state, box)
	Appearance.override_item(row.get_node(^"Selected"), "colors", "font_color", Tokens.color(&"accent_content"))
	var selected_box = StyleBoxFlat.new()
	Appearance.write(selected_box, ^"bg_color", Tokens.color(&"accent"))
	Appearance.override_item(row.get_node(^"Selected"), "styles", "normal", selected_box)
