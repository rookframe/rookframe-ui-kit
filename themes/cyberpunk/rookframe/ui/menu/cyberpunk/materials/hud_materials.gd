@tool
extends RefCounted
## HUD Materials: the alloy keycaps, emissive signals and virtual chassis reused
## for stacked tiles, the emblem action, the bar rail and the vital tracks.
const SLOTS := ["normal", "hover", "pressed", "hover_pressed", "disabled"]
const CONDITION := {"normal": "resting", "hover": "hovered", "pressed": "pressed", "hover_pressed": "pressed", "disabled": "disabled"}
# A selected tile rises out of the rail; its face takes the next emphasis up.
const SELECTED := {"standard": "emissive.resting", "primary": "emissive.pressed", "destructive": "warning.hovered"}
const FACE := {"standard": "alloy", "primary": "emissive", "destructive": "warning"}


static func materials(menu: Dictionary) -> Dictionary:
	var values := {
		"hud.signal": Color("f277c7"),
		"hud.signal.hover": Color("ff9fd9"),
		"hud.signal.pressed": Color("d4559f"),
		"hud.signal.edge": Color("ffd0ec"),
		"hud.signal.ink": Color("1c0617"),
		"hud.signal.ink.disabled": Color("9a8794"),
		# Untracked Exo 2: Button measures whole words without glyph spacing, so a
		# tracked label could break inside its widest word.
		"hud.tile.font": menu["type.display.medium"],
		"hud.tile.font_size": 16,
		"hud.tile.font_size.compact": 14,
		# Stacked content has no inline gap; inherited inline spacing would narrow the label.
		"hud.tile.h_separation": 0,
		"hud.tile.icon": 28,
		"hud.tile.icon.compact": 22,
		"hud.tile.height": 74,
		"hud.tile.height.compact": 56,
		"hud.emblem.icon": 38,
		"hud.emblem.icon.compact": 28,
		"hud.row.separation": 10,
		"hud.row.separation.medium": 8,
		"hud.row.separation.compact": 6,
		"hud.rule.separation": 8,
		"hud.identity.height": 74,
		"hud.identity.height.compact": 56,
		"hud.identity.copy_width": 210,
		"hud.identity.copy_width.compact": 150,
		"hud.favorite.checked": preload("favorite_checked.svg"),
		"hud.favorite.unchecked": preload("favorite_unchecked.svg"),
		"hud.favorite.checked_disabled": preload("favorite_checked_disabled.svg"),
		"hud.favorite.unchecked_disabled": preload("favorite_unchecked_disabled.svg"),
	}
	var dark_ink: Color = menu["button.primary.font_pressed_color"]
	# Stacked tiles: the same keycap faces with a vertical inset for icon over label.
	for usage in FACE:
		for compact in [false, true]:
			var suffix := ".compact" if compact else ""
			for slot in SLOTS:
				var condition: String = CONDITION[slot]
				var source: String = FACE[usage] + "." + condition
				var selected: bool = slot in ["pressed", "hover_pressed"]
				if selected:
					source = SELECTED[usage]
				var face := _face(menu, source)
				face.content_margin_left = 8 if compact else 10
				face.content_margin_right = face.content_margin_left
				face.content_margin_top = 6 if compact else 10
				face.content_margin_bottom = 8 if compact else 13
				if selected:
					# Raised, not sunk: the face extends above the rail with a bright crown.
					face.expand_margin_top = 4.0 if compact else 6.0
					face.border_width_top = 3
					face.border_color = menu["button.standard.font_hover_color"] if usage != "destructive" else Color("ffd5ca")
					if slot == "hover_pressed":
						face.bg_color = face.bg_color.lightened(0.12)
				values["hud.tile." + usage + "." + slot + suffix] = face
			values["hud.tile." + usage + ".focus" + suffix] = _ring(menu["signal.adornment.focus"] if usage != "destructive" else menu["warning.focus"])
		# Selected surfaces carry their contrasting foreground for labels and icons.
		var selected_ink: Color = dark_ink if usage != "destructive" else menu["button.destructive.font_hover_color"]
		for slot in ["pressed", "hover_pressed"]:
			values["hud.tile." + usage + ".ink." + slot] = selected_ink
	# Emblem: the single signal-pink action that leads the bar.
	var emblem := {
		"normal": [values["hud.signal"], values["hud.signal.edge"]],
		"hover": [values["hud.signal.hover"], Color.WHITE],
		"pressed": [values["hud.signal.pressed"], values["hud.signal.edge"]],
		"hover_pressed": [values["hud.signal.pressed"], Color.WHITE],
		"disabled": [Color("3a2433"), Color("6b4a5e")],
	}
	for compact in [false, true]:
		var suffix := ".compact" if compact else ""
		for slot in SLOTS:
			var face := _face(menu, "emissive." + CONDITION[slot])
			face.bg_color = emblem[slot][0]
			face.border_color = emblem[slot][1]
			face.border_width_top = 2
			face.border_width_right = 2
			face.border_width_bottom = 2
			face.corner_radius_top_right = 14
			face.corner_radius_bottom_left = 14
			var inset := 8 if compact else 12
			face.content_margin_left = inset
			face.content_margin_right = inset
			# Match the keycap travel: pressed content sinks with the face.
			var sunk := 3 if CONDITION[slot] == "pressed" else 0
			face.content_margin_top = inset + sunk
			face.content_margin_bottom = inset + 4 - sunk
			values["hud.emblem." + slot + suffix] = face
		values["hud.emblem.focus" + suffix] = _ring(menu["signal.adornment.focus"])
		# A stacked emblem keeps the signal faces with the tile inset and raised selection.
		for slot in SLOTS:
			var tile: StyleBoxFlat = values["hud.emblem." + slot + suffix].duplicate()
			var standard: StyleBoxFlat = values["hud.tile.standard." + slot + suffix]
			for side in [SIDE_LEFT, SIDE_TOP, SIDE_RIGHT, SIDE_BOTTOM]:
				tile.set_content_margin(side, standard.get_content_margin(side))
			tile.expand_margin_top = standard.expand_margin_top
			tile.expand_margin_bottom = standard.expand_margin_bottom
			if slot in ["pressed", "hover_pressed"]:
				tile.bg_color = values["hud.signal.hover"]
				tile.border_color = Color.WHITE
				tile.border_width_top = 3
			values["hud.tile.emblem." + slot + suffix] = tile
		values["hud.tile.emblem.focus" + suffix] = values["hud.emblem.focus" + suffix]
	# Bar chassis: the menu tray framed by a lit signal rail, heavier along the top.
	var rail: Color = menu["button.standard.icon_normal_color"]
	for profile in ["", ".medium", ".compact"]:
		var inset: int = {"": 14, ".medium": 10, ".compact": 6}[profile]
		var bar: StyleBoxFlat = menu["chassis.tray"].duplicate()
		bar.bg_color = Color("08121cf5")
		bar.border_color = rail
		bar.border_width_top = 2
		bar.border_width_left = 1
		bar.border_width_right = 1
		bar.border_width_bottom = 1
		bar.shadow_offset = Vector2(0, 8)
		bar.shadow_size = 8
		bar.content_margin_left = inset
		bar.content_margin_right = inset
		# Selected tiles rise above the row; the top inset leaves them room.
		bar.content_margin_top = inset + 4
		bar.content_margin_bottom = inset
		values["hud.bar" + profile] = bar
		# The attached tray is a tab standing on that rail: open below, its frame
		# tucked under the rail (the presentation removes the container gap).
		var attached: StyleBoxFlat = bar.duplicate()
		attached.bg_color = Color("0b1824f5")
		attached.border_color = Color("4b8996")
		attached.border_width_top = 1
		attached.border_width_left = 2
		attached.border_width_right = 2
		attached.border_width_bottom = 0
		attached.corner_radius_bottom_left = 0
		attached.shadow_size = 0
		attached.expand_margin_bottom = 2.0
		attached.content_margin_top = inset
		attached.content_margin_bottom = inset
		values["hud.attached" + profile] = attached
	var rule := StyleBoxLine.new()
	rule.vertical = true
	rule.color = Color("4b8996")
	rule.thickness = 2
	rule.grow_begin = -8.0
	rule.grow_end = -8.0
	values["hud.rule"] = rule
	# Identity plate: a glass record on an alloy spine; focus keeps the white ring.
	var plates := {"normal": ["0d1c29", menu["alloy.resting.border"].border_color], "hover": ["14293a", menu["alloy.hovered.border"].border_color], "pressed": ["091621", menu["alloy.pressed.border"].border_color], "hover_pressed": ["0f2231", menu["alloy.hovered.border"].border_color], "disabled": ["0b141c", menu["alloy.disabled.border"].border_color]}
	for compact in [false, true]:
		var suffix := ".compact" if compact else ""
		for slot in plates:
			var plate := StyleBoxFlat.new()
			plate.bg_color = Color(plates[slot][0])
			plate.border_color = plates[slot][1]
			plate.border_width_left = 3
			plate.border_width_top = 1
			plate.border_width_right = 1
			plate.border_width_bottom = 1
			plate.corner_radius_top_right = 9
			plate.corner_radius_bottom_left = 9
			plate.corner_detail = 1
			plate.content_margin_left = 8 if compact else 10
			plate.content_margin_right = 10 if compact else 14
			plate.content_margin_top = 5 if compact else 7
			plate.content_margin_bottom = 5 if compact else 7
			values["hud.identity." + slot + suffix] = plate
		values["hud.identity.focus" + suffix] = _ring(menu["signal.adornment.focus"])
	# Vital tracks: level differs in hue, luminance and shape (slanted lead, alarm frame).
	var track := StyleBoxFlat.new()
	track.bg_color = Color("050d14")
	track.border_color = Color("31556a")
	track.set_border_width_all(1)
	track.corner_radius_top_right = 4
	track.corner_radius_bottom_left = 4
	track.corner_detail = 1
	track.content_margin_top = 5
	track.content_margin_bottom = 5
	values["hud.vital.track"] = track
	var alarm: StyleBoxFlat = track.duplicate()
	alarm.border_color = Color("ff6f7d")
	alarm.set_border_width_all(2)
	alarm.bg_color = Color("1e0910")
	values["hud.vital.track.critical"] = alarm
	var spent: StyleBoxFlat = track.duplicate()
	spent.border_color = Color("4a5961")
	spent.bg_color = Color("0b0f12")
	values["hud.vital.track.depleted"] = spent
	var fills := {"": [rail, Vector2.ZERO], ".wounded": [Color("ffc35c"), Vector2(0.6, 0)], ".critical": [Color("ff5d73"), Vector2(0.6, 0)], ".depleted": [Color("4a5961"), Vector2.ZERO]}
	for level in fills:
		var fill: StyleBoxFlat = track.duplicate()
		fill.bg_color = fills[level][0]
		fill.border_color = fills[level][0].lightened(0.35)
		fill.set_border_width_all(0)
		fill.border_width_top = 1
		fill.skew = fills[level][1]
		values["hud.vital.fill" + level] = fill
	# Favorite: a star mark on a bare 44px target; hover lights the cell.
	var cell := StyleBoxEmpty.new()
	for side in [SIDE_LEFT, SIDE_TOP, SIDE_RIGHT, SIDE_BOTTOM]:
		cell.set_content_margin(side, 10)
	values["hud.favorite.normal"] = cell
	var lit := StyleBoxFlat.new()
	lit.bg_color = Color("1c42528c")
	lit.border_color = menu["alloy.hovered.border"].border_color
	lit.border_width_bottom = 2
	lit.corner_radius_top_right = 9
	lit.corner_radius_bottom_left = 9
	lit.corner_detail = 1
	for side in [SIDE_LEFT, SIDE_TOP, SIDE_RIGHT, SIDE_BOTTOM]:
		lit.set_content_margin(side, 10)
	values["hud.favorite.hover"] = lit
	var held: StyleBoxFlat = lit.duplicate()
	held.bg_color = Color("0f24308c")
	held.border_color = menu["alloy.pressed.border"].border_color
	values["hud.favorite.pressed"] = held
	values["hud.favorite.focus"] = menu["signal.adornment.focus"]
	values["hud.emblem.icon_color"] = values["hud.signal.ink"]
	for slot in ["pressed", "hover_pressed"]:
		values["hud.tile.emblem.ink." + slot] = values["hud.signal.ink"]
	return values


static func _face(menu: Dictionary, source: String) -> StyleBoxFlat:
	var face := StyleBoxFlat.new()
	for part in ["surface", "border"]:
		var properties: Dictionary = menu[source + "." + part]
		for property in properties:
			face.set(property, properties[property])
	return face


## A focus ring drawn outside the face so it never merges with a lit surface.
static func _ring(source: StyleBox) -> StyleBox:
	var ring: StyleBoxFlat = source.duplicate()
	for side in [SIDE_LEFT, SIDE_TOP, SIDE_RIGHT, SIDE_BOTTOM]:
		ring.set_expand_margin(side, 3.0)
	return ring

