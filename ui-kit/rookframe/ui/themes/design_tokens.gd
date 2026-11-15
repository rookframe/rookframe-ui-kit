@tool
extends Theme
## Semantic token contract: the names every theme defines under one Theme type,
## and the neutral values that apply wherever a theme leaves a token out.
##
## The dictionaries below are the single source of token names by item type.
## Each key is a token name; each value is its neutral default. Read a token in
## a Control with `get_theme_color(&"surface", &"RookframeTokens")` and its
## siblings, and refresh on `NOTIFICATION_THEME_CHANGED`.
##
## `neutral_tokens.tres` is an instance of this script. Component themes merge
## it beneath their own sources, so every token resolves under any theme entry.

const TYPE := &"RookframeTokens"

## WCAG AA for text.
const AA_MINIMUM := 4.5

## Color items. Every `*_content` color is readable on the surface named before it.
const COLORS := {
	# Canvas
	&"canvas": Color("#1e1e1e"),
	&"scrim": Color(0.0, 0.0, 0.0, 0.6),
	# Surface
	&"surface": Color("#2b2b2b"),
	&"surface_raised": Color("#363636"),
	&"surface_sunken": Color("#232323"),
	&"surface_hover": Color("#404040"),
	&"surface_pressed": Color("#4a4a4a"),
	# Content
	&"content": Color("#e0e0e0"),
	&"content_muted": Color("#a0a0a0"),
	&"content_disabled": Color("#6b6b6b"),
	&"content_heading": Color("#f2f2f2"),
	# Border
	&"border": Color("#555555"),
	&"border_strong": Color("#8c8c8c"),
	&"divider": Color("#3d3d3d"),
	&"focus_ring": Color("#8fb8ec"),
	# Accent
	&"accent": Color("#6f9fd8"),
	&"accent_hover": Color("#86b0e2"),
	&"accent_pressed": Color("#5a8bc7"),
	&"accent_content": Color("#101010"),
	&"accent_subtle": Color("#2e3b4b"),
	# Status
	&"info": Color("#6fa8dc"),
	&"info_surface": Color("#1f2d3b"),
	&"info_content": Color("#cde3f6"),
	&"success": Color("#6dbb74"),
	&"success_surface": Color("#1f3323"),
	&"success_content": Color("#cdeccf"),
	&"warning": Color("#deb256"),
	&"warning_surface": Color("#3a301e"),
	&"warning_content": Color("#f5e3bb"),
	&"danger": Color("#e06c6c"),
	&"danger_surface": Color("#3e2323"),
	&"danger_content": Color("#f7d0d0"),
	# Tabletop
	&"vital_full": Color("#6dbb74"),
	&"vital_wounded": Color("#deb256"),
	&"vital_critical": Color("#e06c6c"),
	&"vital_depleted": Color("#5a5a5a"),
	&"favorite": Color("#e8c04f"),
	&"ornament": Color("#808080"),
	# Elevation
	&"shadow": Color(0.0, 0.0, 0.0, 0.5),
}

## Type roles. Each role is a font item and a font size item of the same name,
## plus the `line_spacing_<role>` constant. The neutral font is Godot's default.
const FONTS: Array[StringName] = [&"display", &"title", &"heading", &"body", &"label", &"value", &"meta", &"mono"]

const FONT_SIZES := {
	&"display": 32,
	&"title": 26,
	&"heading": 20,
	&"body": 16,
	&"label": 16,
	&"value": 24,
	&"meta": 14,
	&"mono": 14,
}

## Constant items in pixels unless noted. `line_spacing_<role>` is extra space
## between lines, as in the native Label `line_spacing` constant. Motion
## durations are milliseconds; `motion_ease` holds a `Tween.TransitionType`.
const CONSTANTS := {
	# Type
	&"line_spacing_display": 3,
	&"line_spacing_title": 3,
	&"line_spacing_heading": 3,
	&"line_spacing_body": 3,
	&"line_spacing_label": 3,
	&"line_spacing_value": 3,
	&"line_spacing_meta": 3,
	&"line_spacing_mono": 3,
	# Space
	&"space_1": 4,
	&"space_2": 8,
	&"space_3": 12,
	&"space_4": 16,
	&"space_5": 24,
	&"space_6": 32,
	&"space_7": 48,
	&"space_8": 64,
	# Shape
	&"radius_small": 4,
	&"radius_medium": 6,
	&"radius_large": 8,
	&"radius_full": 999,
	&"border_width": 1,
	&"border_width_strong": 2,
	&"focus_width": 2,
	# Elevation
	&"elevation_1": 2,
	&"elevation_2": 6,
	&"elevation_3": 12,
	# Size
	&"target_minimum": 44,
	&"icon_small": 16,
	&"icon_medium": 24,
	&"icon_large": 32,
	&"action_height": 52,
	# Motion
	&"motion_fast": 120,
	&"motion_medium": 200,
	&"motion_slow": 320,
	&"motion_ease": Tween.TRANS_CUBIC,
}

## Foreground and background color pairs that must meet `AA_MINIMUM`.
## `content_disabled` is exempt, as WCAG exempts inactive controls.
const AA_PAIRS: Array[Array] = [
	[&"content", &"surface"],
	[&"content", &"surface_raised"],
	[&"content", &"surface_sunken"],
	[&"content_muted", &"surface"],
	[&"content_muted", &"surface_raised"],
	[&"content_muted", &"surface_sunken"],
	[&"content_heading", &"surface"],
	[&"content_heading", &"surface_raised"],
	[&"content_heading", &"surface_sunken"],
	[&"accent_content", &"accent"],
	[&"info_content", &"info_surface"],
	[&"success_content", &"success_surface"],
	[&"warning_content", &"warning_surface"],
	[&"danger_content", &"danger_surface"],
]

## Token names of one item type, in declaration order.
static func names(data_type: Theme.DataType) -> Array[StringName]:
	var result: Array[StringName] = []
	match data_type:
		Theme.DATA_TYPE_COLOR: result.assign(COLORS.keys())
		Theme.DATA_TYPE_CONSTANT: result.assign(CONSTANTS.keys())
		Theme.DATA_TYPE_FONT: result.assign(FONTS)
		Theme.DATA_TYPE_FONT_SIZE: result.assign(FONT_SIZES.keys())
	return result

## Item types that hold tokens.
static func data_types() -> Array[Theme.DataType]:
	return [Theme.DATA_TYPE_COLOR, Theme.DATA_TYPE_CONSTANT, Theme.DATA_TYPE_FONT, Theme.DATA_TYPE_FONT_SIZE]

## Tokens the Theme itself does not define, as `<item type>/<name>`.
static func missing(theme: Theme) -> PackedStringArray:
	var result := PackedStringArray()
	for data_type in data_types():
		# Item lists ignore the Theme's default font and size, unlike `has_font`.
		var defined := theme.get_theme_item_list(data_type, TYPE)
		for item in names(data_type):
			if not defined.has(item):
				result.append(_item_kind(data_type) + "/" + item)
	return result

## AA pairs the Theme defines below `AA_MINIMUM`, with their ratio.
static func contrast_failures(theme: Theme) -> PackedStringArray:
	var result := PackedStringArray()
	for pair in AA_PAIRS:
		if not theme.has_color(pair[0], TYPE) or not theme.has_color(pair[1], TYPE):
			continue
		var ratio := contrast_ratio(theme.get_color(pair[0], TYPE), theme.get_color(pair[1], TYPE))
		if ratio < AA_MINIMUM:
			result.append("%s on %s: %.2f:1" % [pair[0], pair[1], ratio])
	return result

## WCAG 2 contrast ratio. A translucent foreground is composited over the background.
static func contrast_ratio(foreground: Color, background: Color) -> float:
	background.a = 1.0
	var visible := background.lerp(foreground, foreground.a)
	var lighter := maxf(_luminance(visible), _luminance(background))
	var darker := minf(_luminance(visible), _luminance(background))
	return (lighter + 0.05) / (darker + 0.05)

static func _luminance(color: Color) -> float:
	var linear := color.srgb_to_linear()
	return 0.2126 * linear.r + 0.7152 * linear.g + 0.0722 * linear.b

static func _item_kind(data_type: Theme.DataType) -> String:
	match data_type:
		Theme.DATA_TYPE_COLOR: return "colors"
		Theme.DATA_TYPE_CONSTANT: return "constants"
		Theme.DATA_TYPE_FONT: return "fonts"
		Theme.DATA_TYPE_FONT_SIZE: return "font_sizes"
	return "items"

func _init() -> void:
	for item in COLORS:
		set_color(item, TYPE, COLORS[item])
	for item in CONSTANTS:
		set_constant(item, TYPE, CONSTANTS[item])
	for item in FONTS:
		set_font(item, TYPE, ThemeDB.fallback_font)
	for item in FONT_SIZES:
		set_font_size(item, TYPE, FONT_SIZES[item])
