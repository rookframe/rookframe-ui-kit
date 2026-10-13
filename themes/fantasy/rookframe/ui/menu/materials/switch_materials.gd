@tool
extends RefCounted
## The new Fantasy buttons' recessed walnut and beveled brass casing.
const Geometry = preload("switch_geometry.gd")
const Selection = preload("../../_internal/menu/switch_style.gd")


static func materials(menu: Dictionary) -> Dictionary:
	var values := Geometry.values()
	for role in ["title", "description"]:
		values["switch." + role + ".font"] = menu["type.inlay"]
		for state in ["normal", "hover", "pressed", "hover_pressed", "disabled", "selected"]:
			values["switch." + role + "." + state] = menu["choice.ink.disabled"] if state == "disabled" else menu["choice.ink.hover"] if state in ["hover", "hover_pressed", "selected"] else menu["choice.ink"]
	values["switch.ink_shadow"] = Color("140b05")
	values["switch.ink_shadow_size"] = 1
	for compact in [false, true]:
		var suffix := ".compact" if compact else ""
		values["switch.title.size" + suffix] = 23 if compact else 27
		values["switch.description.size" + suffix] = 18 if compact else 20
		values["switch.padding_x" + suffix] = 22 if compact else 30
		for state in ["normal", "hover", "pressed", "hover_pressed", "disabled"]:
			var style := Selection.new()
			style.unselected = _frame(menu, state, false, suffix)
			style.selected = _frame(menu, state, true, suffix)
			style.selected_rtl = style.selected
			values["switch." + state + suffix] = style
		# Focus lights the actual walnut/brass material; no flat overlay.
		values["switch.focus" + suffix] = StyleBoxEmpty.new()
	return values


static func _frame(menu: Dictionary, state: String, selected: bool, suffix: String) -> StyleBox:
	var frame: StyleBox = menu["choice.normal" + suffix].duplicate()
	var hovered := state in ["hover", "hover_pressed"]
	frame.tint = Color("ffe0a3") if selected else Color("f2d5a8") if hovered else Color("a69883")
	if selected and hovered:
		frame.tint = Color("fff0c7")
	if state == "disabled":
		frame.tint = Color("ae9471") if selected else Color("766f64")
	frame.focus_tint = Color(1.35, 1.3, 1.2)
	frame.selection_tint = Color.WHITE
	frame.pressed_offset = 2.0 if state in ["pressed", "hover_pressed"] else 0.0
	return frame
