@tool
extends RefCounted
## Paper means retained narrative: a chronicle to read and revisit.
const Geometry = preload("../../chronicle/chronicle_geometry.gd")
const WORN_EDGE := 48.0


static func materials(menu: Dictionary) -> Dictionary:
	var values := Geometry.geometry()
	values["chronicle.heading.font"] = menu["type.display.medium"]
	values["chronicle.body.font"] = menu["type.ui"]
	values["chronicle.meta.font"] = menu["type.ui.medium"]
	values["chronicle.heading.ink"] = Color("38291c")
	values["chronicle.body.ink"] = Color("3c3024")
	values["chronicle.meta.ink"] = Color("4d3b29")
	var rule := StyleBoxLine.new()
	rule.color = Color("9d805580")
	rule.thickness = 1
	values["chronicle.rule"] = rule
	for compact in [false, true]:
		var surface := StyleBoxTexture.new()
		surface.texture = preload("textures/AI_generated_worn_parchment.png")
		for side in [SIDE_LEFT, SIDE_TOP, SIDE_RIGHT, SIDE_BOTTOM]:
			surface.set_texture_margin(side, WORN_EDGE)
		# Density changes the reading gutter, never the space reserved for wear.
		var padding := WORN_EDGE + (16.0 if compact else 24.0)
		surface.content_margin_left = padding
		surface.content_margin_right = surface.content_margin_left
		surface.content_margin_top = padding
		surface.content_margin_bottom = surface.content_margin_top
		values["chronicle.surface" + (".compact" if compact else "")] = surface
	return values
