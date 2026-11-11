@tool
extends RefCounted
## HUD materials reuse the menu's walnut casing, brass leaf finial, engraved ink
## and carved depth. Tiles stay on the Button presentation; panels use the casing.
const Frame = preload("../../themes/fantasy/hud_frame_style.gd")
const Indicator = preload("../../themes/fantasy/checkbox_icon.gd")
const SLOTS = ["normal", "hover", "pressed", "hover_pressed", "disabled"]

static func materials(button: Dictionary) -> Dictionary:
	var values := {
		"hud.tile.font_size": 19,
		"hud.tile.font_size.compact": 15,
		"hud.tile.icon_max_width": 26,
		"hud.tile.icon_max_width.compact": 22,
		"hud.tile.minimum_height": 52,
		"hud.tile.minimum_height.compact": 44,
		# Tall tiles stretch the walnut instead of thickening the brass rim.
		"hud.tile.art_height": 88,
		"hud.tile.art_height.compact": 76,
		"hud.tile.ink.hover": Color("ffe5ac"),
		# Selected tiles sit into their casing, light it beyond hover and take the
		# brightest engraved ink, so selection never relies on one cue alone.
		"hud.tile.ink.selected": Color("fff4d8"),
		"hud.tile.selected_tint": Color(1.2, 1.08, 0.86),
		"hud.emblem.icon_max_width": 34,
		"hud.emblem.icon_max_width.compact": 28,
		"hud.emblem.minimum_height": 64,
		"hud.emblem.minimum_height.compact": 44,
		# EMBLEM keeps the primary's cast brass leaves beside a square casing;
		# compact density drops them so the bar still fits a narrow parent.
		"hud.emblem.leaf.width": 36,
		"hud.emblem.leaf.height": 24,
		"hud.emblem.leaf.travel": 26,
		"hud.leaf.none": 0,
		# Primary tiles rest in the light that standard tiles reach on hover.
		"hud.primary.cap_tint": Color(1.08, 1.02, 0.9),
		"hud.emblem.leaf.rest": 60,
		"hud.bar.separation": 10,
		"hud.bar.separation.medium": 8,
		"hud.bar.separation.compact": 4,
		"hud.rule.separation": 8,
		"hud.identity.title.size": 20,
		"hud.identity.meta.size": 15,
		"hud.identity.value.size": 22,
		"hud.identity.copy_width.compact": 110,
		"hud.identity.gap": 1,
		"hud.favorite.gap": 0,
		"hud.white": Color.WHITE,
	}
	# Tile faces: the carved style reads these for depth and content placement.
	for compact in [false, true]:
		var suffix := ".compact" if compact else ""
		for slot in SLOTS:
			var sunk: bool = slot in ["pressed", "hover_pressed", "disabled"]
			values["hud.tile." + slot + suffix] = _face(11 if compact else 16, (11 if compact else 15) + (5 if sunk else 0), (16 if compact else 20) - (5 if sunk else 0), sunk)
			values["hud.emblem." + slot + suffix] = _face(10 if compact else 20, (10 if compact else 14) + (5 if sunk else 0), (15 if compact else 19) - (5 if sunk else 0), sunk)
	# Rings sit on the casing itself, inside any leaf clearance.
	values["hud.emblem.focus"] = _ring(Color("f0d391"), 2, -values["hud.emblem.leaf.travel"] + 3, 3)
	values["hud.emblem.focus.compact"] = _ring(Color("f0d391"), 2, 3, 3)
	values["hud.tile.focus"] = _ring(Color("f0d391"), 2, 3, 3)

	# Panels: the bar is the console, its casing quieter than the keys it holds.
	var cap: Texture2D = button["wood.plain.cap"]
	for profile in ["", ".medium", ".compact"]:
		var compact: bool = profile == ".compact"
		var bar := _frame(cap, 10 if compact else 16, Color("a59b89"))
		bar.shadow_size = 12
		bar.shadow_offset = Vector2(0, 6)
		_margins(bar, 10 if compact else 18 if profile == "" else 14, 10 if compact else 13, 12 if compact else 15)
		values["hud.bar.panel" + profile] = bar
		var attached := _frame(cap, 12 if compact else 14, Color("a59b89"))
		attached.shadow_size = 10
		attached.shadow_offset = Vector2(0, 4)
		attached.bridge_height = 10 if compact else 14
		attached.bridge_width = 72 if compact else 96
		attached.bridge_rim = 5
		# Continue under the bar's rim so the bridge reads as one fitting.
		attached.bridge_overlap = 16
		_margins(attached, 12 if compact else 16, 10 if compact else 14, (10 if compact else 14) + attached.bridge_height)
		values["hud.attached.panel" + profile] = attached
	var rule := StyleBoxLine.new()
	rule.vertical = true
	rule.thickness = 2
	rule.color = Color(0.784, 0.647, 0.384, 0.7)
	rule.grow_begin = -10
	rule.grow_end = -10
	values["hud.rule"] = rule

	# Identity plate: one casing; hover lifts the light, press seats the content.
	for compact in [false, true]:
		var suffix := ".compact" if compact else ""
		for slot in SLOTS:
			var plate := _frame(cap, 11 if compact else 13, Color("fff2cf") if slot == "hover" else Color("c7ad89") if slot in ["pressed", "hover_pressed"] else Color("8f877a") if slot == "disabled" else Color("bfb6a6"))
			var seat: int = 2 if slot in ["pressed", "hover_pressed"] else 0
			_margins(plate, 12 if compact else 18, (10 if compact else 13) + seat, (10 if compact else 13) - seat)
			values["hud.identity." + slot + suffix] = plate
		values["hud.identity.focus" + suffix] = _ring(Color("f0d391"), 2, 3, 6)

	# Vital tracks: a recessed brass groove; levels differ in lightness, edge and glow.
	values["hud.vital.track"] = _groove(Color("140e09"), Color("6b5330"), 1, 10)
	values["hud.vital.track.depleted"] = _groove(Color("1c1210"), Color("8a3a2c"), 2, 10)
	values["hud.vital.steady"] = _fill(Color("a9c46a"), Color("e3f0b4"))
	values["hud.vital.wounded"] = _fill(Color("c98a34"), Color("f4cf86"))
	var critical := _fill(Color("9c2a1e"), Color("ffb28f"))
	critical.border_width_bottom = 1
	critical.border_width_left = 1
	critical.border_width_right = 1
	critical.border_color = Color("ffb28f")
	critical.shadow_color = Color("ff4b2b80")
	critical.shadow_size = 4
	values["hud.vital.critical"] = critical
	values["hud.vital.empty"] = StyleBoxEmpty.new()

	# Favorite: a cast brass star, or an engraved outline, carved like the check.
	for selected in [false, true]:
		for disabled in [false, true]:
			var star := Indicator.new()
			star.dimensions = Vector2i(28, 30)
			star.depth = 1.5
			star.shadow_drop = 2.5
			star.cap = preload("favorite_star.svg") if selected else preload("favorite_star_empty.svg")
			star.tint = Color("81796b") if disabled else Color.WHITE if selected else button["wood.resting.cap_tint"]
			star.edge_tint = button["wood.edge.tint"]
			star.shadow_tint = button["wood.shadow.tint"]
			var key := "hud.favorite.checked" if selected else "hud.favorite.unchecked"
			values[key + (".disabled" if disabled else "")] = star
	for slot in ["normal", "hover", "pressed", "hover_pressed", "disabled", "focus"]:
		var surface := StyleBoxFlat.new()
		_margins(surface, 8, 7, 7)
		surface.set_corner_radius_all(4)
		# The cast star carries the checked state; only hover lights the well.
		surface.bg_color = Color("35291d") if slot in ["hover", "hover_pressed"] else Color.TRANSPARENT
		if slot == "focus":
			surface.draw_center = false
			surface.set_border_width_all(2)
			surface.border_color = Color("f0d391")
		values["hud.favorite." + slot] = surface
	return values


static func _face(side: float, top: float, bottom: float, sunk: bool) -> StyleBoxFlat:
	var face := StyleBoxFlat.new()
	face.bg_color = Color("281d16")
	face.expand_margin_top = -5.0 if sunk else 0.0
	face.expand_margin_bottom = -1.0 if sunk else -6.0
	face.content_margin_left = side
	face.content_margin_right = side
	face.content_margin_top = top
	face.content_margin_bottom = bottom
	return face


static func _ring(color: Color, width: int, horizontal: float, vertical: float) -> StyleBoxFlat:
	var ring := StyleBoxFlat.new()
	ring.draw_center = false
	ring.set_border_width_all(width)
	ring.border_color = color
	ring.set_corner_radius_all(6)
	ring.expand_margin_left = horizontal
	ring.expand_margin_right = horizontal
	ring.expand_margin_top = vertical
	ring.expand_margin_bottom = vertical
	return ring


static func _frame(texture: Texture2D, rim: float, tint: Color) -> StyleBox:
	var frame := Frame.new()
	frame.texture = texture
	frame.rim = rim
	frame.tint = tint
	return frame


static func _margins(style: StyleBox, side: float, top: float, bottom: float) -> void:
	style.content_margin_left = side
	style.content_margin_right = side
	style.content_margin_top = top
	style.content_margin_bottom = bottom


static func _groove(fill: Color, edge: Color, width: int, height: float) -> StyleBoxFlat:
	var groove := StyleBoxFlat.new()
	groove.bg_color = fill
	groove.set_border_width_all(width)
	groove.border_width_top = width + 1
	groove.border_color = edge
	groove.set_corner_radius_all(3)
	groove.content_margin_top = height / 2
	groove.content_margin_bottom = height / 2
	return groove


static func _fill(color: Color, light: Color) -> StyleBoxFlat:
	var fill := StyleBoxFlat.new()
	fill.bg_color = color
	fill.border_width_top = 2
	fill.border_color = light
	fill.set_corner_radius_all(3)
	return fill
