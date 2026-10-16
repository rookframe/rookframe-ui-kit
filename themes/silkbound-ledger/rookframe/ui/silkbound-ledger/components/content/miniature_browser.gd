@tool
extends "res://rookframe/ui/components/content/miniature_browser.gd"

func _style_row(row: Button) -> void:
	for state in ["normal", "hover", "pressed", "hover_pressed", "disabled"]:
		var box := StyleBoxFlat.new()
		box.bg_color = Color("bc927726") if state in ["pressed", "hover_pressed"] else Color("080b0a66")
		box.set_border_width_all(1)
		box.border_color = Color("bc9277") if state in ["pressed", "hover_pressed"] else Color("bc927747")
		row.add_theme_stylebox_override(state, box)
	row.get_node(^"Selected").add_theme_color_override("font_color", Color("151719"))
	var selected_box := StyleBoxFlat.new()
	selected_box.bg_color = Color("ceccb3")
	row.get_node(^"Selected").add_theme_stylebox_override("normal", selected_box)
