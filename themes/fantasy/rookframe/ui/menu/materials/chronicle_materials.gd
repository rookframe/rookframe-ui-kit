@tool
extends RefCounted
## Paper means retained narrative: a chronicle to read and revisit.
const Geometry = preload("../../chronicle/chronicle_geometry.gd")
const Paper = preload("../../_internal/menu/vertical_paper_style.gd")
const SCROLL_SIDE := 48.0
const SCROLL_ROLL := 96.0
const SCROLL_TRANSITION := 48.0
const SCROLL_BLEND := 48.0


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
		var surface := Paper.new()
		surface.texture = preload("textures/AI_generated_paper_scroll.png")
		# The imported 768 x 512 texture has a transparent photography margin.
		surface.region = Rect2(24, 28, 720, 452)
		surface.side_width = SCROLL_SIDE
		surface.cap_height = SCROLL_ROLL
		surface.transition_height = SCROLL_TRANSITION
		surface.blend_height = SCROLL_BLEND
		# Preserve the paper rolls and their shadows at both reading densities.
		var gutter := 16.0 if compact else 24.0
		surface.content_margin_left = SCROLL_SIDE + gutter
		surface.content_margin_right = surface.content_margin_left
		surface.content_margin_top = SCROLL_ROLL + gutter
		surface.content_margin_bottom = surface.content_margin_top
		values["chronicle.surface" + (".compact" if compact else "")] = surface
	return values
