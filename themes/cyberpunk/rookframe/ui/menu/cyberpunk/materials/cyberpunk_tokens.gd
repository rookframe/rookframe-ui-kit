@tool
extends RefCounted
## Neon Circuit tokens: the one source of every Cyberpunk color, type face and
## type size. Materials and mappings read these values; none repeats a literal.
##
## `PALETTE` is the private primitive tier: shades a single component material
## needs and no semantic role names. `COLORS`, `CONSTANTS`, `FONTS` and
## `FONT_SIZES` are this theme's `RookframeTokens` values, keyed by the names in
## `res://rookframe/ui/themes/design_tokens.gd`. `apply()` authors them into the
## native Theme; `materials()` exposes them to mappings as `token.<item type>.<name>`.
## Change a token here and every Material and variation that reads it follows.
const Tokens = preload("res://rookframe/ui/themes/design_tokens.gd")

const PALETTE := {
	# Signal cyan: icon ink, the HUD rail and the healthy vital track.
	"signal": Color("7bdde6"),
	"signal_bright": Color("cbfcff"),
	"neon": Color("6bf2ef"),
	"neon_bright": Color("c8ffff"),
	"highlight": Color("ffffff"),
	"identity_ink": Color("8cf4f1"),
	"identity_tint": Color("68eef0"),
	# Alloy keycaps (standard actions) and their machined edges.
	"control_ink": Color("d5f4fa"),
	"control_ink_pressed": Color("9de8ec"),
	"alloy_hovered": Color("1c4253"),
	"alloy_edge": Color("143c4c"),
	"alloy_border": Color("3a788b"),
	"alloy_border_hovered": Color("6cecf1"),
	"alloy_border_pressed": Color("71c9d3"),
	"alloy_border_disabled": Color("324c5b"),
	# Emissive faces (primary actions).
	"emissive": Color("67e7e8"),
	"emissive_border": Color("b6ffff"),
	"emissive_border_hovered": Color("e0ffff"),
	"emissive_pressed": Color("42bfc8"),
	"emissive_border_pressed": Color("75e3e7"),
	"emissive_disabled": Color("203947"),
	"emissive_border_disabled": Color("3b5965"),
	"primary_fill": Color("60ccce"),
	"primary_ink": Color("09232d"),
	# Warning keycaps (destructive actions).
	"warning_border": Color("c86a6b"),
	"warning_hovered": Color("592936"),
	"warning_border_hovered": Color("ffaaa0"),
	"warning_pressed": Color("311820"),
	"warning_border_pressed": Color("e58b81"),
	"warning_disabled": Color("282329"),
	"warning_border_disabled": Color("66515c"),
	"warning_ink_hover": Color("ffe7e2"),
	"warning_ink_pressed": Color("ffd5ca"),
	"warning_ink_disabled": Color("977f84"),
	"warning_focus": Color("ffb8ad"),
	# Chassis frames and rules.
	"structure_edge": Color("102934"),
	"tray_edge": Color("315568"),
	"edge_glint": Color("62e8f0"),
	"signal_rule": Color("509cab"),
	"disabled_fill": Color("182a34"),
	"choice_ink_hover": Color("e9ffff"),
	"selected_hover": Color("2b6779"),
	# HUD signal pink: the emblem action and the favorite star.
	"pink": Color("f277c7"),
	"pink_hover": Color("ff9fd9"),
	"pink_pressed": Color("d4559f"),
	"pink_edge": Color("ffd0ec"),
	"pink_ink": Color("1c0617"),
	"pink_ink_disabled": Color("9a8794"),
	"pink_disabled": Color("3a2433"),
	"pink_border_disabled": Color("6b4a5e"),
	# Vital levels and their alarm frames.
	"amber": Color("ffc35c"),
	"critical": Color("ff5d73"),
	"alarm": Color("ff6f7d"),
	"alarm_fill": Color("1e0910"),
	"spent": Color("4a5961"),
	"spent_fill": Color("0b0f12"),
	# Arc picker medallions.
	"glass_hover": Color("163a4b"),
	"ring": Color("4aa3ad"),
	"arc_icon_disabled": Color("4e6470"),
}

static var COLORS: Dictionary[StringName, Color] = _colors()

## Line heights per type role in pixels; `line_spacing_<role>` is derived from
## each role's face so it remains Godot's extra space between lines.
const LINE_HEIGHTS := {
	&"display": 48, &"title": 38, &"heading": 30, &"body": 29,
	&"label": 26, &"value": 36, &"meta": 24, &"mono": 24,
}

const FONT_SIZES: Dictionary[StringName, int] = {
	&"display": 40, &"title": 30, &"heading": 24, &"body": 21,
	&"label": 20, &"value": 30, &"meta": 18, &"mono": 18,
}

static var FONTS: Dictionary[StringName, Font] = _fonts()
static var CONSTANTS: Dictionary[StringName, int] = _constants()


## A token color, optionally with an 8-bit alpha (0-255) for translucent layers.
static func color(name: StringName, alpha: int = -1) -> Color:
	assert(COLORS.has(name), "Unknown Neon Circuit color token: " + name)
	return _alpha(COLORS[name], alpha)


## A private palette shade, optionally with an 8-bit alpha.
static func shade(name: String, alpha: int = -1) -> Color:
	assert(PALETTE.has(name), "Unknown Neon Circuit palette shade: " + name)
	return _alpha(PALETTE[name], alpha)


## Author every token under `RookframeTokens`.
static func apply(theme: Theme) -> void:
	for item in COLORS:
		theme.set_color(item, Tokens.TYPE, COLORS[item])
	for item in CONSTANTS:
		theme.set_constant(item, Tokens.TYPE, CONSTANTS[item])
	for item in FONTS:
		theme.set_font(item, Tokens.TYPE, FONTS[item])
	for item in FONT_SIZES:
		theme.set_font_size(item, Tokens.TYPE, FONT_SIZES[item])


## Material references for mappings: `token.colors.content`, `token.fonts.body`,
## `token.font_sizes.body` and `token.constants.space_2`.
static func materials() -> Dictionary:
	var values := {}
	for item in COLORS:
		values["token.colors." + item] = COLORS[item]
	for item in CONSTANTS:
		values["token.constants." + item] = CONSTANTS[item]
	for item in FONTS:
		values["token.fonts." + item] = FONTS[item]
	for item in FONT_SIZES:
		values["token.font_sizes." + item] = FONT_SIZES[item]
	return values


static func _alpha(source: Color, alpha: int) -> Color:
	return source if alpha < 0 else Color(source, alpha / 255.0)


static func _colors() -> Dictionary[StringName, Color]:
	var colors: Dictionary[StringName, Color] = {
		# Canvas: the bare chassis and the escape backdrop.
		&"canvas": Color("070d16"),
		&"scrim": Color("020910dc"),
		# Surface: settings sheets, glass records, control faces and their states.
		&"surface": Color("0d1b27"),
		&"surface_raised": Color("152f3e"),
		&"surface_sunken": Color("09131e"),
		&"surface_hover": Color("244f60"),
		&"surface_pressed": Color("102633"),
		# Content: running copy, metadata, unavailable ink and headings.
		&"content": Color("c4d5df"),
		&"content_muted": Color("a2c4d2"),
		&"content_disabled": Color("8199a5"),
		&"content_heading": Color("e5f9ff"),
		# Border: control edges, record frames, rules and the white focus ring.
		&"border": Color("416978"),
		&"border_strong": Color("4a8993"),
		&"divider": Color("41606c"),
		&"focus_ring": Color("f4fafa"),
		# Accent: the cyan selection signal and its emissive states.
		&"accent": Color("81e7e8"),
		&"accent_hover": Color("99eded"),
		&"accent_pressed": Color("459fa9"),
		&"accent_content": Color("04151c"),
		&"accent_subtle": Color("205263"),
		# Status. Info is the signal keycap; danger is the destructive keycap.
		&"info": PALETTE.signal,
		&"info_content": PALETTE.control_ink,
		&"success": Color("7af5b0"),
		&"warning": PALETTE.amber,
		&"danger": Color("ff918c"),
		&"danger_surface": Color("401e29"),
		&"danger_content": Color("ffc7c0"),
		# Tabletop.
		&"vital_full": PALETTE.signal,
		&"vital_wounded": PALETTE.amber,
		&"vital_critical": PALETTE.critical,
		&"vital_depleted": PALETTE.spent,
		&"favorite": PALETTE.pink,
		&"ornament": Color("57dbe5"),
		# Elevation: the chassis drop shade.
		&"shadow": Color("000000a0"),
	}
	colors[&"info_surface"] = colors[&"surface_raised"]
	# Success and warning have no keycap of their own. Like the destructive
	# keycap, each surface keeps a quarter of its signal's brightness and its ink
	# lifts the signal halfway to white.
	for status in [&"success", &"warning"]:
		colors[StringName(status + "_surface")] = colors[status].darkened(0.75)
		colors[StringName(status + "_content")] = colors[status].lerp(Color.WHITE, 0.5)
	return colors


static func _fonts() -> Dictionary[StringName, Font]:
	var ui: FontVariation = preload("ui.tres")
	var display: Font = preload("display.tres")
	# Literal text keeps the running face with tabular figures and a slashed zero.
	var mono := FontVariation.new()
	mono.base_font = ui.base_font
	mono.variation_opentype = ui.variation_opentype
	mono.opentype_features = {TextServerManager.get_primary_interface().name_to_tag("tnum"): 1, TextServerManager.get_primary_interface().name_to_tag("zero"): 1}
	return {
		&"display": display, &"title": display, &"heading": display,
		&"body": ui, &"label": preload("control.tres"), &"value": display,
		&"meta": ui, &"mono": mono,
	}


static func _constants() -> Dictionary[StringName, int]:
	var constants: Dictionary[StringName, int] = {
		# Space: the shared scale; Neon Circuit keeps its density.
		&"space_1": 4, &"space_2": 8, &"space_3": 12, &"space_4": 16,
		&"space_5": 24, &"space_6": 32, &"space_7": 48, &"space_8": 64,
		# Shape: frames are chamfered in their StyleBoxes; radii stay small.
		&"radius_small": 2, &"radius_medium": 4, &"radius_large": 8, &"radius_full": 999,
		&"border_width": 1, &"border_width_strong": 3, &"focus_width": 2,
		# Elevation: keycap, popup/medallion and sheet drop shades.
		&"elevation_1": 3, &"elevation_2": 6, &"elevation_3": 12,
		# Size.
		&"target_minimum": 44, &"icon_small": 16, &"icon_medium": 24, &"icon_large": 32,
		&"action_height": 60,
		# Motion: the keycap hover; transitions ease quadratically.
		&"motion_fast": 100, &"motion_medium": 200, &"motion_slow": 320,
		&"motion_ease": Tween.TRANS_QUAD,
	}
	for role in FONT_SIZES:
		var height := FONTS[role].get_height(FONT_SIZES[role])
		constants[StringName("line_spacing_" + role)] = int(round(LINE_HEIGHTS[role] - height))
	return constants
