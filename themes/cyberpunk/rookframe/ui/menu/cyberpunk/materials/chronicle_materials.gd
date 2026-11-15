@tool
extends RefCounted
## The same retained narrative is an archive panel in the Cyberpunk theme.
const Geometry = preload("../../../chronicle/chronicle_geometry.gd")
const Layers = preload("../../../_internal/menu/layered_style.gd")
const T = preload("cyberpunk_tokens.gd")


static func materials(menu: Dictionary) -> Dictionary:
	var values := Geometry.geometry()
	values["chronicle.heading.font"] = menu["type.display.medium"]
	values["chronicle.body.font"] = menu["type.ui"]
	values["chronicle.meta.font"] = menu["type.ui.medium"]
	values["chronicle.heading.ink"] = T.color(&"content_heading")
	values["chronicle.body.ink"] = T.color(&"content")
	values["chronicle.meta.ink"] = T.color(&"content_muted")
	var rule := StyleBoxLine.new()
	rule.color = T.color(&"divider")
	rule.thickness = 1
	values["chronicle.rule"] = rule
	for compact in [false, true]:
		var surface := Layers.new()
		var face := StyleBoxFlat.new()
		face.bg_color = T.color(&"surface")
		face.border_color = T.color(&"divider")
		face.border_width_left = 1
		face.border_width_top = 1
		face.border_width_right = 1
		face.border_width_bottom = 1
		face.corner_radius_top_right = 8
		face.corner_radius_bottom_right = 8
		face.shadow_color = T.color(&"shadow", 0x66)
		face.shadow_size = 4
		face.shadow_offset = Vector2(0, 3)
		surface.layers.append(face)
		# A permanent archive binding; the quiet reading field stays unobstructed.
		var binding := StyleBoxTexture.new()
		binding.texture = preload("archive_binding.svg")
		binding.texture_margin_left = 64
		binding.texture_margin_right = 48
		binding.texture_margin_top = 24
		binding.texture_margin_bottom = 24
		surface.layers.append(binding)
		surface.content_margin_left = 22 if compact else 30
		surface.content_margin_right = surface.content_margin_left
		surface.content_margin_top = 22 if compact else 30
		surface.content_margin_bottom = surface.content_margin_top
		values["chronicle.surface" + (".compact" if compact else "")] = surface
	return values
