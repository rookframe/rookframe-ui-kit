@tool
extends RefCounted
## Reuse the new Cyberpunk alloy switches, emissive actions and virtual chassis.
const Geometry = preload("../../../editor/materials/editor_materials.gd")


static func materials(menu: Dictionary) -> Dictionary:
	var values := Geometry.geometry()
	values["editor.font"] = menu["type.control"]
	values["editor.heading.ink"] = menu["title.font_color"]
	values["editor.body.ink"] = menu["body.font_color"]
	values["editor.meta.ink"] = menu["meta.font_color"]
	values["editor.accent.ink"] = menu["button.standard.icon_normal_color"]
	values["editor.rule"] = menu["signal.rule"]
	for compact in [false, true]:
		var suffix := ".compact" if compact else ""
		for kind in ["tool", "action", "standard"]:
			for state in ["normal", "hover", "pressed", "hover_pressed", "disabled", "focus"]:
				var condition: String = {"normal": "resting", "hover": "hovered", "pressed": "pressed", "hover_pressed": "pressed", "disabled": "disabled", "focus": "resting"}[state]
				var material: String = "emissive" if kind == "action" else "alloy"
				var face := StyleBoxFlat.new()
				for part in ["surface", "border"]:
					for property in menu[material + "." + condition + "." + part]:
						face.set(property, menu[material + "." + condition + "." + part][property])
				face.content_margin_left = 12 if kind == "tool" else 20
				face.content_margin_right = face.content_margin_left
				face.content_margin_top = 10
				face.content_margin_bottom = 14
				if condition == "pressed":
					face.content_margin_top += 3
					face.content_margin_bottom -= 3
					face.border_width_bottom = 3
					face.border_color = menu["button.standard.icon_hover_color"]
				values["editor." + kind + "." + state + suffix] = menu["signal.adornment.focus"] if state == "focus" else face
				var ink_slot: String = "font_color" if state == "normal" else "font_" + ("pressed" if state == "hover_pressed" else state) + "_color"
				values["editor." + kind + ".ink." + state] = menu["button." + ("primary" if kind == "action" else "standard") + "." + ink_slot]
		for kind in ["rail", "panel", "inset", "log"]:
			var surface: StyleBox = menu["glass.record" if kind == "log" else "chassis.structure" if kind == "inset" else "chassis.tray"].duplicate()
			var padding: int = 8 if kind == "rail" else 12 if compact else 18
			surface.content_margin_left = padding
			surface.content_margin_right = padding
			surface.content_margin_top = padding
			surface.content_margin_bottom = padding
			values["editor.surface." + kind + suffix] = surface
	return values
