@tool
extends RefCounted
## Reuse the new Fantasy cartouche, walnut tray, stone grain and brass inlay.
const Geometry = preload("../../editor/materials/editor_materials.gd")
const Layers = preload("../../_internal/menu/layered_style.gd")


static func materials(menu: Dictionary) -> Dictionary:
	var values := Geometry.geometry()
	values["editor.font"] = menu["choice.font"]
	values["editor.heading.ink"] = menu["choice.ink"]
	values["editor.body.ink"] = menu["body.font_color"]
	values["editor.meta.ink"] = menu["meta.font_color"]
	values["editor.accent.ink"] = menu["choice.ink"]
	values["editor.rule"] = menu["brass.rule"]
	for compact in [false, true]:
		var suffix := ".compact" if compact else ""
		for kind in ["tool", "action", "standard"]:
			for state in ["normal", "hover", "pressed", "hover_pressed", "disabled", "focus"]:
				var slot: String = "normal" if state == "focus" else state
				var frame: StyleBox = menu["choice." + slot + suffix].duplicate()
				if kind == "action":
					frame.focus_tint = Color(1.4, 1.28, 1.12)
					if slot == "normal":
						frame.focus_tint /= frame.tint
					frame.texture = menu["wood.brass.cap"]
					frame.finial = menu["brass.adornment"]
					frame.source_margin = Vector2(260, 40)
					frame.finial_fraction = Vector2(0.34, 0.25)
					frame.content_margin_left = 32 if compact else 38
					frame.content_margin_right = frame.content_margin_left
				elif kind == "tool":
					frame.content_margin_left = 14
					frame.content_margin_right = 14
				else:
					frame.content_margin_left = 16 if compact else 20
					frame.content_margin_right = frame.content_margin_left
				# Selection lights the existing material, as keyboard focus does.
				frame.selection_tint = frame.focus_tint
				values["editor." + kind + "." + state + suffix] = StyleBoxEmpty.new() if state == "focus" else frame
				values["editor." + kind + ".ink." + state] = menu["choice.ink.disabled"] if state == "disabled" else menu["choice.ink.hover"] if state in ["hover", "focus", "pressed", "hover_pressed"] else menu["choice.ink"]
		for kind in ["rail", "panel", "inset", "log"]:
			var padding: int = 8 if kind == "rail" else 12 if compact else 18
			var surface: StyleBox
			if kind in ["inset", "log"]:
				surface = menu["choice.popup"].duplicate()
			else:
				surface = Layers.new()
				surface.layers.append(menu["stone.tray"].duplicate())
				var stone := StyleBoxTexture.new()
				stone.texture = menu["stone.grain"]
				stone.modulate_color = menu["stone.grain.tint"]
				stone.axis_stretch_horizontal = StyleBoxTexture.AXIS_STRETCH_MODE_TILE
				stone.axis_stretch_vertical = StyleBoxTexture.AXIS_STRETCH_MODE_TILE
				surface.layers.append(stone)
				surface.layers.append(menu["stone.inner_edge"])
			surface.content_margin_left = padding
			surface.content_margin_right = padding
			surface.content_margin_top = padding
			surface.content_margin_bottom = padding
			values["editor.surface." + kind + suffix] = surface
	return values
