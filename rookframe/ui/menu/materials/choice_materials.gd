@tool
extends RefCounted
## Walnut and cast brass. All choice-specific appearance is authored here.
const Frame = preload("../../_internal/menu/choice_frame.gd")
const Layers = preload("../../_internal/menu/layered_style.gd")
const CAP = preload("walnut_brass_cap.tres")
const FINIAL = preload("brass_leaf_finial.tres")
const GOLD := Color("f3d78e")
static var VALUES := _materials()


static func _materials() -> Dictionary:
	var values := {
		"choice.font": preload("display_medium.tres"),
		"choice.ink": GOLD,
		"choice.ink.hover": Color("ffe8ac"),
		"choice.ink.disabled": Color("968264"),
		"choice.outline": Color("1d1008"),
		"choice.outline_size": 1,
		"choice.arrow": preload("choice_arrow.svg"),
		"choice.check": preload("choice_check.svg"),
		"choice.blank": _blank(),
		"choice.modulate_arrow": 0,
		"choice.selection_disabled": Color("887c68"),
		"choice.selection_inset": 22,
		"choice.popup_inset": 30,
		"choice.popup_inset.compact": 23,
		"choice.popup_overlap": 7,
		"choice.popup_overlap.compact": 5,
		"choice.font_size": 27,
		"choice.font_size.compact": 22,
		"choice.height": 64,
		"choice.height.compact": 48,
		"choice.arrow_margin": 54,
		"choice.arrow_margin.compact": 47,
		"choice.copy_gap": 14,
		"choice.popup_gap": 12,
		"choice.popup_gap.compact": 10,
		"choice.popup_start": 30,
		"choice.popup_start.compact": 24,
		"choice.popup_end": 58,
		"choice.popup_h_gap": 0,
	}
	for compact in [false, true]:
		var suffix := ".compact" if compact else ""
		for state in ["normal", "hover", "pressed", "hover_pressed", "disabled"]:
			var frame := Frame.new()
			frame.texture = CAP
			frame.finial = FINIAL
			frame.content_margin_left = 46 if compact else 58
			frame.content_margin_right = 58 if compact else 76
			frame.content_margin_top = 6 if compact else 10
			frame.content_margin_bottom = 9 if compact else 13
			frame.tint = Color("b5aaa0") if state == "disabled" else Color("fff2cf") if state == "hover" else Color("c7ad89") if state in ["pressed", "hover_pressed"] else Color.WHITE
			frame.pressed_offset = 1.5 if state in ["pressed", "hover_pressed"] else 0.0
			values["choice." + state + suffix] = frame
		var focus := StyleBoxFlat.new()
		focus.bg_color = Color.TRANSPARENT
		focus.border_color = Color("fff0b6")
		focus.border_width_top = 2
		focus.border_width_bottom = 2
		focus.expand_margin_left = -42 if compact else -54
		focus.expand_margin_right = focus.expand_margin_left
		focus.expand_margin_top = -8
		focus.expand_margin_bottom = -10
		values["choice.focus" + suffix] = focus
	values["choice.popup"] = _tray()
	var hover := StyleBoxFlat.new()
	hover.bg_color = Color("ad61044d")
	hover.border_color = Color("cd841780")
	hover.border_width_top = 1
	hover.border_width_bottom = 1
	values["choice.popup_hover"] = hover
	return values


static func _blank() -> GradientTexture2D:
	var texture := GradientTexture2D.new()
	texture.width = 1
	texture.height = 1
	texture.gradient = Gradient.new()
	texture.gradient.colors = PackedColorArray([Color.TRANSPARENT, Color.TRANSPARENT])
	return texture


static func _tray() -> StyleBox:
	var tray := Layers.new()
	tray.content_margin_left = 5
	tray.content_margin_right = 5
	tray.content_margin_top = 5
	tray.content_margin_bottom = 7
	var shadow := StyleBoxFlat.new()
	shadow.bg_color = Color("140c06")
	shadow.shadow_color = Color("000000b8")
	shadow.shadow_size = 7
	shadow.shadow_offset = Vector2(0, 5)
	tray.layers.append(shadow)
	# The same walnut face continues from the closed control into the tray.
	var grain := AtlasTexture.new()
	grain.atlas = CAP.atlas
	grain.region = Rect2(300, 260, 1400, 230)
	grain.filter_clip = true
	var wood := StyleBoxTexture.new()
	wood.texture = grain
	wood.modulate_color = Color("c5a78b")
	wood.axis_stretch_vertical = StyleBoxTexture.AXIS_STRETCH_MODE_TILE
	tray.layers.append(wood)
	var edge := StyleBoxFlat.new()
	edge.bg_color = Color.TRANSPARENT
	edge.border_color = Color("533313")
	edge.set_border_width_all(4)
	tray.layers.append(edge)
	var brass := StyleBoxFlat.new()
	brass.bg_color = Color.TRANSPARENT
	brass.border_color = Color("d3a449")
	brass.set_border_width_all(1)
	brass.set_expand_margin_all(-2)
	tray.layers.append(brass)
	var corner := StyleBoxFlat.new()
	corner.bg_color = Color("8d5f22")
	corner.border_color = Color("d8ad58")
	corner.set_border_width_all(1)
	corner.shadow_color = Color("1b0d04cc")
	corner.shadow_size = 1
	corner.shadow_offset = Vector2(1, 1)
	tray.corner = corner
	tray.corner_size = Vector2(8, 8)
	return tray
