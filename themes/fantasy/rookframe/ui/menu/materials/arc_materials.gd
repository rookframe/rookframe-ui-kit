@tool
extends RefCounted
## Arc picker medallions: bevelled brass rings around dark walnut wells, iron
## rails with a dark core, and a stone-dark caption. Stock StyleBoxFlat layers
## keep every ring resolution independent and the hit bounds unchanged.
const Layers = preload("../../_internal/menu/layered_style.gd")

# 46 keeps the 44px target and lets five categories share the default sweep.
const CATEGORY_DIAMETER := 46
const ITEM_DIAMETER := 76
# The item ring occupies the well inset; the core Well covers everything inside it.
const WELL_INSET := 7
const CATEGORY_RING := 5
# Selection widens the ring outward, so the preview keeps its size.
const SELECTED_OUTSET := 2
# Brass from the Fantasy checkmark and bronze bevels; iron from the steel caps.
const BRASS := {
	"normal": {"rim": Color("201508"), "body": Color("b4863a"), "light": Color("f0ce79"), "shade": Color("6a4416")},
	"hover": {"rim": Color("201508"), "body": Color("cf9f48"), "light": Color("fff0b0"), "shade": Color("7e541d")},
	"pressed": {"rim": Color("201508"), "body": Color("e8b955"), "light": Color("fff6cc"), "shade": Color("8d571d")},
	"hover_pressed": {"rim": Color("201508"), "body": Color("f3c86a"), "light": Color("fffbe6"), "shade": Color("9a6424")},
	"disabled": {"rim": Color("080b09"), "body": Color("4a514c"), "light": Color("687366"), "shade": Color("171d19")},
}
const WELL := Color("15110c")
const WELL_DISABLED := Color("1b1e1c")


static func materials(menu: Dictionary) -> Dictionary:
	var values := {
		"arc.category.diameter": CATEGORY_DIAMETER,
		"arc.item.diameter": ITEM_DIAMETER,
		"arc.item.well_inset": WELL_INSET,
		"arc.category.icon_max_width": CATEGORY_DIAMETER - 2 * 12,
		"arc.category.icon": menu["choice.ink"],
		"arc.category.icon.hover": menu["choice.ink.hover"],
		"arc.category.icon.selected": Color("fff3cf"),
		"arc.category.icon.disabled": Color("6d6a60"),
		# Iron at rest, the menu's brass while the track is active; both over a dark core.
		"arc.rail": Color("8d958a"),
		"arc.rail.active": Color("e2b457"),
		"arc.rail.core": Color("140e07"),
		"arc.rail.width": 6,
		"arc.rail.core_width": 2,
		"arc.arrow.size": 22,
		"arc.arrow": preload("arc_arrow.svg"),
		"arc.selection_mark": preload("arc_selection_mark.svg"),
		"arc.well": _well(),
		"arc.caption": _caption(menu),
		"arc.caption.kicker.font": menu["type.inlay"],
		"arc.caption.kicker.size": 15,
		"arc.caption.kicker.ink": menu["identity.tint"],
		"arc.caption.title.font": menu["type.display.medium"],
		"arc.caption.title.size": 22,
		"arc.caption.title.ink": menu["title.font_color"],
		"arc.caption.outline": menu["brass.inlay.groove"],
		"arc.caption.outline_size": 2,
	}
	for state in BRASS:
		var outset := SELECTED_OUTSET if state in ["pressed", "hover_pressed"] else 0
		var center := WELL_DISABLED if state == "disabled" else WELL
		values["arc.category." + state] = _ring(BRASS[state], CATEGORY_RING, outset, center, 12)
		values["arc.item." + state] = _ring(BRASS[state], WELL_INSET, outset, center, WELL_INSET)
	var focus_ring: Color = menu["brass.focus"].border_color
	values["arc.category.focus"] = _focus(focus_ring, SELECTED_OUTSET + 3)
	values["arc.item.focus"] = _focus(focus_ring, SELECTED_OUTSET + 3)
	return values


## A carved ring: dark outer rim, brass body lit from the top left, a dark inner
## rim and a recessed centre. `outset` grows the ring outward only.
static func _ring(palette: Dictionary, thickness: int, outset: int, center: Color, padding: int) -> StyleBox:
	var ring := Layers.new()
	var rim := _disc(palette.rim, outset)
	rim.shadow_color = Color(0, 0, 0, 0.55)
	rim.shadow_size = 4
	rim.shadow_offset = Vector2(0, 2)
	ring.layers.append(rim)
	ring.layers.append(_disc(palette.body, outset - 1))
	ring.layers.append(_crescent(palette.light, outset - 1, true, 3))
	ring.layers.append(_crescent(palette.shade, outset - 1, false, 3))
	# The inner bevel is reversed: the recess is shaded at the top and lit below.
	ring.layers.append(_crescent(palette.shade, -(thickness - 2), true, 1))
	ring.layers.append(_crescent(palette.light, -(thickness - 2), false, 1))
	ring.layers.append(_disc(palette.rim, -(thickness - 1)))
	ring.layers.append(_disc(center, -thickness))
	ring.layers.append(_crescent(Color(0, 0, 0, 0.5), -thickness, true, 3))
	for side in [SIDE_LEFT, SIDE_TOP, SIDE_RIGHT, SIDE_BOTTOM]:
		ring.set_content_margin(side, padding)
	return ring


static func _disc(fill: Color, grow: float) -> StyleBoxFlat:
	var disc := StyleBoxFlat.new()
	disc.bg_color = fill
	disc.set_corner_radius_all(1024)
	disc.corner_detail = 20
	disc.set_expand_margin_all(grow)
	return disc


## Light from the top left: a border on two sides of a disc is a tapering crescent.
static func _crescent(tint: Color, grow: float, upper: bool, width: int) -> StyleBoxFlat:
	var crescent := _disc(Color.TRANSPARENT, grow)
	crescent.draw_center = false
	crescent.border_color = tint
	var minor := maxi(1, width - 1)
	crescent.border_width_top = width if upper else 0
	crescent.border_width_left = minor if upper else 0
	crescent.border_width_bottom = 0 if upper else width
	crescent.border_width_right = 0 if upper else minor
	return crescent


## Keyboard focus: the menu's brass focus colour as a separate outer ring, with a
## dark halo so it reads over bright and dark scenes alike.
static func _focus(tint: Color, gap: int) -> StyleBox:
	var focus := Layers.new()
	var halo := _disc(Color.TRANSPARENT, gap + 3)
	halo.draw_center = false
	halo.set_border_width_all(4)
	halo.border_color = Color(0.03, 0.02, 0.01, 0.7)
	focus.layers.append(halo)
	var ring := _disc(Color.TRANSPARENT, gap + 2)
	ring.draw_center = false
	ring.set_border_width_all(2)
	ring.border_color = tint
	focus.layers.append(ring)
	return focus


## The Well stylebox is the preview's clip mask; only its shape matters.
static func _well() -> StyleBoxFlat:
	var well := _disc(WELL, 0)
	well.anti_aliasing_size = 1.0
	return well


static func _caption(menu: Dictionary) -> StyleBox:
	var plate := StyleBoxFlat.new()
	plate.bg_color = Color("15110ce8")
	plate.border_color = menu["brass.inlay.cut_edge"]
	plate.set_border_width_all(1)
	plate.set_corner_radius_all(4)
	plate.shadow_color = Color(0, 0, 0, 0.45)
	plate.shadow_size = 6
	plate.shadow_offset = Vector2(0, 2)
	plate.content_margin_left = 16
	plate.content_margin_right = 16
	plate.content_margin_top = 6
	plate.content_margin_bottom = 8
	return plate
