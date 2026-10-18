@tool
extends RefCounted
## Checkbox materials share the button's walnut, brass, engraving and depth.
const Indicator = preload("../../themes/fantasy/checkbox_icon.gd")

static func materials(button: Dictionary) -> Dictionary:
	var values := {
		"checkbox.gap": 12,
		"checkbox.white": Color.WHITE,
		"checkbox.ink.hover": Color("ffe5ac"),
	}
	for selected in [false, true]:
		for disabled in [false, true]:
			var indicator := Indicator.new()
			indicator.dimensions = Vector2i(32, 34)
			indicator.depth = 2.0
			indicator.shadow_drop = 3.0
			indicator.inset = 7.0
			indicator.cap = button["wood.plain.cap"]
			indicator.mark = preload("choice_check.svg")
			indicator.selected = selected
			indicator.tint = Color("81796b") if disabled else button["wood.cap.tint"] if selected else button["wood.resting.cap_tint"]
			indicator.mark_tint = Color("aa9980") if disabled else Color.WHITE
			indicator.edge_tint = button["wood.edge.tint"]
			indicator.shadow_tint = button["wood.shadow.tint"]
			var key := "checkbox.checked" if selected else "checkbox.unchecked"
			values[key + (".disabled" if disabled else "")] = indicator
	for state in ["normal", "hover", "pressed", "hover_pressed", "disabled", "focus"]:
		var surface := StyleBoxFlat.new()
		surface.content_margin_left = 8
		surface.content_margin_right = 12
		surface.content_margin_top = 5
		surface.content_margin_bottom = 5
		surface.set_corner_radius_all(3)
		surface.bg_color = Color("211b15")
		if state in ["hover", "hover_pressed"]:
			surface.bg_color = Color("35291d")
		elif state == "pressed":
			surface.bg_color = Color("292016")
		elif state == "disabled":
			surface.bg_color = Color("211e19")
		elif state == "focus":
			surface.draw_center = false
			surface.set_border_width_all(1)
			surface.border_color = button["button.standard.font_color"]
		values["checkbox." + state] = surface
	return values
