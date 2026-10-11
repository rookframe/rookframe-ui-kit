@tool
extends RefCounted
## Reuse the new menu buttons' machined alloy faces, bevels and cyan signals.
const Geometry = preload("../../materials/switch_geometry.gd")
const Selection = preload("../../../_internal/menu/switch_style.gd")


static func materials(menu: Dictionary) -> Dictionary:
	var values := Geometry.values()
	for role in ["title", "description"]:
		values["switch." + role + ".font"] = menu["type.control" if role == "title" else "type.ui"]
		for state in ["normal", "hover", "pressed", "hover_pressed", "disabled", "selected"]:
			values["switch." + role + "." + state] = menu["button.standard.font_disabled_color"] if state == "disabled" else menu["button.standard.font_hover_color"] if state in ["hover", "hover_pressed"] else menu["body.font_color"] if role == "description" else menu["button.standard.font_color"]
	values["switch.ink_shadow"] = Color.TRANSPARENT
	values["switch.ink_shadow_size"] = 0
	for compact in [false, true]:
		var suffix := ".compact" if compact else ""
		for state in ["normal", "hover", "pressed", "hover_pressed", "disabled"]:
			var style := Selection.new()
			style.unselected = _face(menu, state, false, false)
			style.selected = _face(menu, state, true, false)
			style.selected_rtl = _face(menu, state, true, true)
			values["switch." + state + suffix] = style
		values["switch.focus" + suffix] = menu["signal.adornment.focus"]
	return values


static func _face(menu: Dictionary, state: String, selected: bool, rtl: bool) -> StyleBoxFlat:
	var condition: String = {"normal": "resting", "hover": "hovered", "pressed": "pressed", "hover_pressed": "hovered", "disabled": "disabled"}[state]
	var face := StyleBoxFlat.new()
	for part in ["surface", "border"]:
		for property in menu["alloy." + condition + "." + part]:
			face.set(property, menu["alloy." + condition + "." + part][property])
	face.border_width_left = 1
	face.border_width_bottom = 3
	if selected:
		face.border_color = menu["button.standard.icon_disabled_color" if state == "disabled" else "button.standard.icon_hover_color"]
		face.border_width_left = 1 if rtl else 4
		face.border_width_right = 4 if rtl else 1
		face.bg_color = menu["alloy." + ("disabled" if state == "disabled" else "hovered") + ".surface"].bg_color
	return face
