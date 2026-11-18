@tool
extends Theme
## Silkbound Ledger's semantic token values: the single source for this theme.
##
## `silkbound_tokens.tres` is an instance of this script. The canonical entry
## lists it in `supplemental_themes`, so these values replace the neutral set.
## Authored Theme and scene values that play a token's role name it in their
## `metadata/tokens` (property -> token, or [token, alpha]);
## `tools/apply-silkbound-tokens.gd` writes the values below into them, and its
## `--check` mode reports any that drift. Presentation scripts read `color()`.
##
## Names come from `res://rookframe/ui/themes/design_tokens.gd`.

const TYPE := &"RookframeTokens"

const COLORS := {
	# Canvas
	&"canvas": Color("#151719"),
	&"scrim": Color(0.0, 0.0, 0.0, 0.667),
	# Surface: hover lifts above raised; pressed sinks between surface and raised.
	# Authored controls mark these states with edges over the `ledger_*` primitives.
	&"surface": Color("#23282b"),
	&"surface_raised": Color("#343d41"),
	&"surface_sunken": Color("#151719"),
	&"surface_hover": Color("#3c464b"),
	&"surface_pressed": Color("#2c3337"),
	# Content
	&"content": Color("#e7e7dd"),
	&"content_muted": Color("#aebabe"),
	# Dimmer than muted, so an inactive control reads apart from secondary text.
	&"content_disabled": Color("#788387"),
	&"content_heading": Color("#e7e7dd"),
	# Border: controls are outlined in copper at 38%, so the edge takes the tone of
	# the surface behind it; panels keep the grey `ledger_edge` primitive.
	&"border": Color(0.737255, 0.572549, 0.466667, 0.38),
	&"border_strong": Color("#ceccb3"),
	&"divider": Color("#3e4346"),
	&"focus_ring": Color("#e7e7dd"),
	# Accent: neutral paper fills with ink foregrounds; the subtle fill is
	# `surface` with 15% paper.
	&"accent": Color("#ceccb3"),
	&"accent_hover": Color("#e7e7dd"),
	&"accent_pressed": Color("#b6b49e"),
	&"accent_content": Color("#151719"),
	&"accent_subtle": Color("#3d413f"),
	# Status: every tone sits on the ordinary surface and carries its color in the foreground.
	&"info": Color("#d0be8e"),
	&"info_surface": Color("#23282b"),
	&"info_content": Color("#d0be8e"),
	&"success": Color("#93c49a"),
	&"success_surface": Color("#23282b"),
	&"success_content": Color("#93c49a"),
	&"warning": Color("#dfba74"),
	&"warning_surface": Color("#23282b"),
	&"warning_content": Color("#dfba74"),
	&"danger": Color("#ff817a"),
	&"danger_surface": Color("#23282b"),
	&"danger_content": Color("#ff817a"),
	# Tabletop
	&"vital_full": Color("#ceccb3"),
	&"vital_wounded": Color("#bc9277"),
	&"vital_critical": Color("#ff817a"),
	&"vital_depleted": Color(0.682353, 0.729412, 0.745098, 0.45),
	&"favorite": Color("#d0be8e"),
	&"ornament": Color("#bc9277"),
	# Elevation
	&"shadow": Color(0.082353, 0.090196, 0.098039, 0.6),
}

## Theme-private colors with no semantic token. Packages never read these.
const PRIMITIVES := {
	&"pictogram": Color("#d0be8e"),
	&"section_count": Color("#d9ae94"),
	&"ribbon": Color("#bd5b68"),
	# The grey outline of authored panels, cards, popups and shell controls.
	&"ledger_edge": Color("#5b6265"),
	# The one raised fill authored controls keep under the pointer, while
	# pressed and when selected; their edges tell the states apart.
	&"ledger_hover": Color("#343d41"),
	&"ledger_pressed": Color("#343d41"),
	&"ledger_selected": Color("#343d41"),
}

## Font resource per type role.
const FONTS := {
	&"display": "res://rookframe/ui/theme/silkbound_display.tres",
	&"title": "res://rookframe/ui/theme/silkbound_display.tres",
	&"heading": "res://rookframe/ui/theme/silkbound_display.tres",
	&"body": "res://rookframe/ui/theme/silkbound_regular.tres",
	&"label": "res://rookframe/ui/theme/silkbound_display.tres",
	&"value": "res://rookframe/ui/theme/silkbound_regular.tres",
	&"meta": "res://rookframe/ui/theme/silkbound_regular.tres",
	&"mono": "res://rookframe/ui/theme/silkbound_regular.tres",
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

## Line box per type role in pixels. `line_spacing_<role>` is derived from it
## as the extra space beyond the role font's own line height.
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

const CONSTANTS := {
	# Space
	&"space_1": 4,
	&"space_2": 8,
	&"space_3": 12,
	&"space_4": 16,
	&"space_5": 24,
	&"space_6": 32,
	&"space_7": 48,
	&"space_8": 64,
	# Shape: square corners; circular actions take the full radius.
	&"radius_small": 0,
	&"radius_medium": 0,
	&"radius_large": 0,
	&"radius_full": 999,
	&"border_width": 1,
	&"border_width_strong": 2,
	&"focus_width": 2,
	# Elevation: owning surfaces are flat; floating medallions and captions cast shadows.
	&"elevation_1": 0,
	&"elevation_2": 3,
	&"elevation_3": 6,
	# Size
	&"target_minimum": 44,
	&"icon_small": 16,
	&"icon_medium": 24,
	&"icon_large": 30,
	&"action_height": 52,
	# Motion
	&"motion_fast": 120,
	&"motion_medium": 200,
	&"motion_slow": 320,
	&"motion_ease": Tween.TRANS_CUBIC,
}

## A semantic color or a theme-private primitive by name.
static func color(name: StringName) -> Color:
	return COLORS[name] if COLORS.has(name) else PRIMITIVES[name]

func _init() -> void:
	for item in COLORS:
		set_color(item, TYPE, COLORS[item])
	for item in CONSTANTS:
		set_constant(item, TYPE, CONSTANTS[item])
	for role in FONTS:
		var font: Font = load(FONTS[role])
		set_font(role, TYPE, font)
		set_font_size(role, TYPE, FONT_SIZES[role])
		set_constant(StringName("line_spacing_" + role), TYPE, LINE_HEIGHTS[role] - ceili(font.get_height(FONT_SIZES[role])))
