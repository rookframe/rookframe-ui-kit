@tool
extends RefCounted
const Appearance = preload("res://rookframe/ui/_internal/presentation/appearance.gd")




func _style_row(control, row: Button) -> void:
	for state in ["normal", "hover", "pressed", "hover_pressed", "disabled"]:
		var box = StyleBoxFlat.new()
		Appearance.write(box, ^"bg_color", Color("bc927726") if state in ["pressed", "hover_pressed"] else Color("080b0a66"))
		box.set_border_width_all(1)
		Appearance.write(box, ^"border_color", Color("bc9277") if state in ["pressed", "hover_pressed"] else Color("bc927747"))
		Appearance.override_item(row, "styles", state, box)
	Appearance.override_item(row.get_node(^"Selected"), "colors", "font_color", Color("151719"))
	var selected_box = StyleBoxFlat.new()
	Appearance.write(selected_box, ^"bg_color", Color("ceccb3"))
	Appearance.override_item(row.get_node(^"Selected"), "styles", "normal", selected_box)
