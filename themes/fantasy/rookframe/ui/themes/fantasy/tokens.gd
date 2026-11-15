@tool
extends RefCounted
## Fantasy semantic token values: the one place each `RookframeTokens` value is
## authored. `menu/fantasy_theme.gd` publishes them as `RookframeTokens` items in
## the native Theme, and Materials that carry a semantic role (type, text inks,
## accent, focus, surfaces, status, vitals, scrim, shadow, motion) read the same
## entries, so every type variation and presentation built from them follows a
## change made here. Material-only values (casings, bevels, tints) stay in Materials.
## Names and value types follow res://rookframe/ui/themes/design_tokens.gd.
const Contract = preload("res://rookframe/ui/themes/design_tokens.gd")
const DISPLAY_FACE = preload("res://rookframe/ui/menu/materials/display_medium.tres")
const BODY_FACE = preload("res://rookframe/ui/assets/fonts/Inter-VariableFont_opsz,wght.ttf")

const COLORS := {
	# Canvas: the dark table beneath the stone; the Escape backdrop.
	&"canvas": Color("0e110f"),
	&"scrim": Color("030605dc"),
	# Surface: Settings panel; World list rows and panel.
	&"surface": Color("1b211e"),
	&"surface_raised": Color("252d27"),
	&"surface_sunken": Color("171c18"),
	&"surface_hover": Color("394337"),
	&"surface_pressed": Color("1c241e"),
	# Content: menu body, metadata and title ink; disabled engraved Button ink.
	&"content": Color(0.85, 0.81, 0.72, 1),
	&"content_muted": Color(0.69, 0.65, 0.555, 1),
	&"content_disabled": Color("847456"),
	&"content_heading": Color(0.95, 0.905, 0.8, 1),
	# Border: Settings edge and rule; a selected World row; brass keyboard focus.
	&"border": Color("756443"),
	&"border_strong": Color("e2c184"),
	&"divider": Color("655d49"),
	&"focus_ring": Color("e2c184"),
	# Accent: brass, lit like the bronze bevel on hover and shaded when pressed;
	# the bronze rim is its ink. A selected World row is the subtle fill.
	&"accent": Color("e2c184"),
	&"accent_hover": Color("f0d091"),
	&"accent_pressed": Color("a88854"),
	&"accent_content": Color("201508"),
	&"accent_subtle": Color("4c452b"),
	# Status: iron, the vital greens, amber and oxblood. Each surface mixes 20%
	# of its color into `surface`; each content is the matching light ink.
	&"info": Color("8d958a"),
	&"info_surface": Color("323834"),
	&"info_content": Color("b2baaa"),
	&"success": Color("a9c46a"),
	&"success_surface": Color("37422d"),
	&"success_content": Color("c4d899"),
	&"warning": Color("c98a34"),
	&"warning_surface": Color("3e3622"),
	&"warning_content": Color("f4cf86"),
	&"danger": Color("ff918c"),
	&"danger_surface": Color("35231e"),
	&"danger_content": Color("f0c9b5"),
	# Tabletop: vital fills and the depleted groove edge; the cast star's brass;
	# the brass of the rook pictogram and rules.
	&"vital_full": Color("a9c46a"),
	&"vital_wounded": Color("c98a34"),
	&"vital_critical": Color("9c2a1e"),
	&"vital_depleted": Color("8a3a2c"),
	&"favorite": Color("f0ce79"),
	&"ornament": Color(0.718, 0.608, 0.376, 1),
	# Elevation: the Settings panel shadow.
	&"shadow": Color(0, 0, 0, 0.6),
}

## The display face (EB Garamond Medium) titles screens and sections; Inter
## carries everything else. The theme ships no monospace face.
const FONTS := {
	&"display": DISPLAY_FACE,
	&"title": DISPLAY_FACE,
	&"heading": DISPLAY_FACE,
	&"body": BODY_FACE,
	&"label": BODY_FACE,
	&"value": BODY_FACE,
	&"meta": BODY_FACE,
	&"mono": BODY_FACE,
}

const FONT_SIZES := {
	&"display": 40,
	&"title": 30,
	&"heading": 24,
	&"body": 21,
	&"label": 20,
	&"value": 30,
	&"meta": 18,
	&"mono": 18,
}

## Line height in pixels per type role. It is published as Godot's extra
## `line_spacing_<role>`: this height less the face's own line height at its size.
const LINE_HEIGHTS := {
	&"display": 48,
	&"title": 38,
	&"heading": 30,
	&"body": 29,
	&"label": 26,
	&"value": 36,
	&"meta": 24,
	&"mono": 24,
}

## Every constant except `line_spacing_<role>`, which LINE_HEIGHTS derives.
const CONSTANTS := {
	&"space_1": 4,
	&"space_2": 8,
	&"space_3": 12,
	&"space_4": 16,
	&"space_5": 24,
	&"space_6": 32,
	&"space_7": 48,
	&"space_8": 64,
	# Cap and focus corners, HUD rings, the metal socket.
	&"radius_small": 5,
	&"radius_medium": 6,
	&"radius_large": 7,
	&"radius_full": 999,
	&"border_width": 1,
	&"border_width_strong": 2,
	&"focus_width": 2,
	# Resting cap depth, the choice tray, the Settings panel and HUD bar.
	&"elevation_1": 5,
	&"elevation_2": 7,
	&"elevation_3": 12,
	&"target_minimum": 44,
	&"icon_small": 16,
	&"icon_medium": 24,
	&"icon_large": 32,
	# The regular secondary Button.
	&"action_height": 50,
	# Carved Button hover and release; the kit's slow duration.
	&"motion_fast": 70,
	&"motion_medium": 110,
	&"motion_slow": 320,
	&"motion_ease": Tween.TRANS_QUAD,
}


## Extra line spacing of one type role.
static func line_spacing(role: StringName) -> int:
	return LINE_HEIGHTS[role] - roundi((FONTS[role] as Font).get_height(FONT_SIZES[role]))


## Material references `token.<item type>.<name>` for mappings.
static func materials() -> Dictionary:
	var values := {}
	for name in COLORS:
		values["token.color." + name] = COLORS[name]
	for name in FONTS:
		values["token.font." + name] = FONTS[name]
		values["token.font_size." + name] = FONT_SIZES[name]
		values["token.constant.line_spacing_" + name] = line_spacing(name)
	for name in CONSTANTS:
		values["token.constant." + name] = CONSTANTS[name]
	return values


## Publish every token as a `RookframeTokens` item of `theme`.
static func apply(theme: Theme) -> void:
	for name in COLORS:
		theme.set_color(name, Contract.TYPE, COLORS[name])
	for name in FONTS:
		theme.set_font(name, Contract.TYPE, FONTS[name])
		theme.set_font_size(name, Contract.TYPE, FONT_SIZES[name])
		theme.set_constant(StringName("line_spacing_" + name), Contract.TYPE, line_spacing(name))
	for name in CONSTANTS:
		theme.set_constant(name, Contract.TYPE, CONSTANTS[name])
