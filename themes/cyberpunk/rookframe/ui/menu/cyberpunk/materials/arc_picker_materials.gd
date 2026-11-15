@tool
extends RefCounted
## Arc picker Materials: a neon rail with a dark core, dark-glass medallions with
## signal rings and a chamfered HUD readout, all drawn from the existing palette.
const T = preload("cyberpunk_tokens.gd")
static var PALETTE: Dictionary = {
	"glass": T.color(&"surface", 0xf0),
	"glass_hover": T.shade("glass_hover", 0xf2),
	"ring": T.shade("ring"),
	"ring_hover": T.color(&"accent"),
	"signal": T.shade("neon"),
	"signal_hover": T.shade("neon_bright"),
	"emissive": T.shade("primary_fill"),
	"emissive_hover": T.color(&"accent_hover"),
	"core": T.color(&"canvas"),
	"focus": T.color(&"focus_ring"),
	"shade": T.color(&"shadow"),
	"glow": T.shade("neon", 0x70),
	"glow_hover": T.shade("neon", 0xa0),
}


static func _medallion(fill: Color, ring: Color, width: int, shade: Color, shade_size: int, drop := 0.0) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = fill
	box.border_color = ring
	box.set_border_width_all(width)
	# Oversized radii resolve to a circle at any diameter the Theme supplies.
	box.set_corner_radius_all(128)
	box.corner_detail = 16
	box.shadow_color = shade
	box.shadow_size = shade_size
	box.shadow_offset = Vector2(0, drop)
	return box


# Unavailable entries lose the lit signal ring for a broken, unpowered one, so
# the state never depends on colour while a host preview still fills the well.
static func _offline() -> StyleBoxTexture:
	var box := StyleBoxTexture.new()
	box.texture = preload("arc_offline_ring.svg")
	return box


static func materials(menu: Dictionary) -> Dictionary:
	var values := {
		"arc.rail": Color(PALETTE.ring, 0.95),
		"arc.rail.active": PALETTE.signal,
		"arc.rail.core": PALETTE.core,
		"arc.rail_width": 6,
		"arc.rail_core_width": 2,
		"arc.arrow_size": 14,
		"arc.arrow": preload("arc_arrow.svg"),
		"arc.category.diameter": 52,
		"arc.category.icon_max_width": 24,
		"arc.item.diameter": 76,
		"arc.item.well_inset": 7,
		"arc.selection_mark": preload("arc_selection_mark.svg"),
		"arc.icon": menu["button.standard.icon_normal_color"],
		"arc.icon.hover": menu["button.standard.icon_hover_color"],
		"arc.icon.focus": menu["button.standard.icon_focus_color"],
		"arc.icon.selected": menu["button.primary.font_color"],
		"arc.icon.disabled": T.shade("arc_icon_disabled"),
		"arc.caption.kicker": menu["subtitle.font_color"],
		"arc.caption.title": menu["title.font_color"],
		"arc.caption.kicker.font": menu["type.control"],
		"arc.caption.title.font": menu["type.display.medium"],
		"arc.caption.kicker.size": 13,
		"arc.caption.title.size": 19,
	}
	for kind in ["category", "item"]:
		var item: bool = kind == "item"
		var faces := {
			"normal": _medallion(PALETTE.glass, PALETTE.ring, 2, PALETTE.shade, 6, 2.0),
			"hover": _medallion(PALETTE.glass_hover, PALETTE.ring_hover, 2, PALETTE.shade, 6, 2.0),
			"disabled": _offline(),
		}
		if item:
			# Selected items keep the glass and gain a heavier, glowing signal ring.
			faces["pressed"] = _medallion(PALETTE.glass, PALETTE.signal, 4, PALETTE.glow, 10)
			faces["hover_pressed"] = _medallion(PALETTE.glass_hover, PALETTE.signal_hover, 4, PALETTE.glow_hover, 12)
		else:
			# The open category lights up as an emissive face with dark ink.
			faces["pressed"] = _medallion(PALETTE.emissive, PALETTE.signal_hover, 2, PALETTE.glow, 10)
			faces["hover_pressed"] = _medallion(PALETTE.emissive_hover, PALETTE.signal_hover, 2, PALETTE.glow_hover, 12)
		for state in faces:
			var face: StyleBox = faces[state]
			face.set_content_margin_all(14.0 if not item else 0.0)
			values["arc.%s.%s" % [kind, state]] = face
		# A separate white ring outside the medallion with a dark halo, so focus
		# reads over bright and dark scenes and never relies on the fill.
		var focus := _medallion(Color.TRANSPARENT, PALETTE.focus, 3, PALETTE.core, 3)
		focus.draw_center = false
		focus.set_expand_margin_all(5.0)
		values["arc.%s.focus" % kind] = focus
	var well := _medallion(Color.WHITE, Color.WHITE, 0, Color.TRANSPARENT, 0)
	values["arc.well"] = well
	var caption: StyleBoxFlat = menu["glass.record"].duplicate()
	caption.bg_color = T.color(&"surface_sunken", 0xf0)
	caption.border_color = PALETTE.ring
	caption.border_width_left = 3
	caption.border_width_right = 1
	caption.border_width_top = 1
	caption.border_width_bottom = 1
	caption.corner_radius_top_right = 8
	caption.corner_radius_bottom_left = 8
	caption.shadow_size = 6
	caption.shadow_offset = Vector2(0, 3)
	caption.content_margin_left = 14.0
	caption.content_margin_right = 12.0
	caption.content_margin_top = 5.0
	caption.content_margin_bottom = 7.0
	values["arc.caption"] = caption
	return values
