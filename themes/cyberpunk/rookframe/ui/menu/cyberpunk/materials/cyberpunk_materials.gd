@tool
extends RefCounted
## Neon Circuit Material: concrete geometry lives here or in its native resources;
## every color, type face and role size comes from cyberpunk_tokens.gd.
const T = preload("cyberpunk_tokens.gd")
const CLEAR := Color(0, 0, 0, 0)
static var VALUES: Dictionary = {
	"type.ui": T.FONTS[&"body"],
	"type.ui.medium": T.FONTS[&"meta"],
	"type.display.medium": T.FONTS[&"display"],
	"type.control": T.FONTS[&"label"],
	"default.font_size": 18,
	"title.font_size": 68,
	"title.shadow_offset_y": 2,
	"title.line_spacing": -4,
	"subtitle.font_size": 32,
	"body.font_size": 18,
	"meta.font_size": 13,
	"worldtitle.font_size": 30,
	"worldbody.font_size": 16,
	"worldmeta.font_size": 12,
	"compacttitle.font_size": 46,
	"brandcompact.font_size": 26,
	"rule.separation": 2,
	"surface.grain_inset": 2,
	"surface.edge_inset": 7,
	"title.font_color": T.color(&"content_heading"),
	"title.font_shadow_color": T.color(&"canvas"),
	"subtitle.font_color": T.shade("identity_ink"),
	"body.font_color": T.color(&"content"),
	"meta.font_color": T.color(&"content_muted"),
	"worldtitle.font_color": T.color(&"content_heading"),
	"worldbody.font_color": T.color(&"content"),
	"worldmeta.font_color": T.color(&"content_muted"),
	"worldsuccess.font_color": T.color(&"success"),
	"identity.tint": T.shade("identity_tint"),
	"chassis.grain.tint": Color(1.000000, 1.000000, 1.000000, 0.000000),
	"glass.grain.tint": Color(1.000000, 1.000000, 1.000000, 0.000000),
	"chassis.structure": _tinted(preload("structure.tres"), T.color(&"canvas"), T.shade("structure_edge")),
	"chassis.tray": _tinted(preload("tray.tres"), T.color(&"surface_sunken", 0xea), T.shade("tray_edge")),
	"chassis.inner_edge": _tinted(preload("edge.tres"), CLEAR, T.shade("edge_glint", 0x19)),
	"glass.record": _tinted(preload("glass.tres"), T.color(&"surface", 0xf5), T.color(&"border_strong")),
	"signal.rule": _ruled(preload("rule.tres"), T.shade("signal_rule")),
	"signal.perimeter": _tinted(preload("perimeter.tres"), CLEAR, T.color(&"ornament", 0x57)),
	"signal.adornment.focus": _tinted(preload("focus.tres"), CLEAR, T.color(&"focus_ring")),
	"image.atmosphere": preload("AI_generated_neon-city.png"),
	"chassis.grain": preload("blank.tres"),
	"glass.grain": preload("blank.tres"),
	"alloy.cap": preload("blank.tres"),
	"signal.adornment": preload("signal.svg"),
	"image.identity": preload("../../icons/AI_generated_chess-rook.svg"),
	"image.worlds": preload("../../icons/AI_generated_world.svg"),
	"image.packages": preload("../../icons/AI_generated_stack-2.svg"),
	"image.settings": preload("../../icons/AI_generated_settings.svg"),
	"image.open": preload("../../icons/AI_generated_arrow-right.svg"),
	"outline.none": StyleBoxEmpty.new(),
	"alloy.texture_visible": 0,
	"alloy.cap_depth": 4,
	"alloy.shadow_drop": 5,
	"alloy.patch_side": 1,
	"alloy.patch_rail": 1,
	"alloy.ornament_width": 4,
	"alloy.ornament_height": 28,
	"alloy.ornament_travel": 7,
	"alloy.ornament_ms": 100,
	"alloy.icons_visible": 1,
	"alloy.cap.tint": Color(1.000000, 1.000000, 1.000000, 1.000000),
	"alloy.edge.tint": T.shade("alloy_edge"),
	"alloy.shadow.tint": T.color(&"shadow", 0x80),
	"signal.inlay.groove": Color(0.000000, 0.000000, 0.000000, 0.000000),
	"signal.inlay.cut_edge": Color(0.000000, 0.000000, 0.000000, 0.000000),
	"signal.primary.ornament_rest": 35,
	"signal.standard.ornament_rest": 0,
	"signal.destructive.ornament_width": 0,
	"signal.destructive.ornament_travel": 0,
	"warning.focus": _tinted(preload("destructive_focus.tres"), CLEAR, T.shade("warning_focus")),
	"button.destructive.font_color": T.color(&"danger_content"),
	"button.destructive.font_hover_color": T.shade("warning_ink_hover"),
	"button.destructive.font_pressed_color": T.shade("warning_ink_pressed"),
	"button.destructive.font_focus_color": T.shade("warning_ink_hover"),
	"button.destructive.font_disabled_color": T.shade("warning_ink_disabled"),
	"signal.inlay.outline_size": 0,
	"signal.inlay.shadow_offset_x": 0,
	"signal.inlay.shadow_offset_y": 0,
	"signal.inlay.shadow_outline_size": 0,
	"button.standard.outline_size": 0,
	"button.primary.height": 64,
	"button.primary.height.compact": 44,
	"button.standard.height": 60,
	"button.standard.height.compact": 44,
	"alloy.buttons.inset": 0,
	"button.standard.font_size": 21,
	"button.compact.font_size": 18,
	"button.standard.h_separation": 14,
	"button.compact.h_separation": 12,
	"button.standard.icon_max_width": 22,
	"button.compact.icon_max_width": 20,
	"switch.motion.hover_ms": 100,
	"switch.motion.press_ms": 45,
	"switch.motion.release_ms": 130,
	"switch.motion.transition": Tween.TRANS_QUAD,
	"switch.motion.ease": Tween.EASE_OUT,
	"button.standard.font_color": T.shade("control_ink"),
	"button.standard.font_hover_color": T.shade("highlight"),
	"button.standard.font_pressed_color": T.shade("control_ink_pressed"),
	"button.standard.font_focus_color": T.shade("highlight"),
	"button.standard.font_disabled_color": T.color(&"content_disabled"),
	"button.primary.font_color": T.color(&"accent_content"),
	"button.primary.font_hover_color": T.color(&"accent_content"),
	"button.primary.font_pressed_color": T.color(&"accent_content"),
	"button.primary.font_focus_color": T.color(&"accent_content"),
	"button.primary.font_disabled_color": T.color(&"content_disabled"),
	"button.standard.icon_normal_color": T.shade("signal"),
	"button.standard.icon_hover_color": T.shade("signal_bright"),
	"button.standard.icon_pressed_color": T.shade("control_ink_pressed"),
	"button.standard.icon_focus_color": T.shade("highlight"),
	"button.standard.icon_disabled_color": T.color(&"content_disabled"),
	"alloy.resting.surface": {"bg_color": T.color(&"surface_raised"), "expand_margin_top": 0.0, "expand_margin_bottom": -4.0, "shadow_color": T.color(&"shadow", 0x88), "shadow_size": 3, "shadow_offset": Vector2(0, 4), "corner_radius_top_right": 9, "corner_radius_bottom_left": 9, "corner_detail": 1},
	"alloy.resting.border": {"border_width_left": 3, "border_width_top": 1, "border_width_right": 1, "border_width_bottom": 1, "border_color": T.shade("alloy_border")},
	"alloy.hovered.surface": {"bg_color": T.shade("alloy_hovered"), "expand_margin_top": 0.0, "expand_margin_bottom": -4.0, "shadow_color": T.color(&"shadow", 0x88), "shadow_size": 3, "shadow_offset": Vector2(0, 4), "corner_radius_top_right": 9, "corner_radius_bottom_left": 9, "corner_detail": 1},
	"alloy.hovered.border": {"border_width_left": 3, "border_width_top": 1, "border_width_right": 1, "border_width_bottom": 1, "border_color": T.shade("alloy_border_hovered")},
	"alloy.pressed.surface": {"bg_color": T.color(&"surface_pressed"), "expand_margin_top": -3.0, "expand_margin_bottom": -1.0, "shadow_color": T.color(&"shadow", 0x88), "shadow_size": 3, "shadow_offset": Vector2(0, 4), "corner_radius_top_right": 9, "corner_radius_bottom_left": 9, "corner_detail": 1},
	"alloy.pressed.border": {"border_width_left": 3, "border_width_top": 1, "border_width_right": 1, "border_width_bottom": 1, "border_color": T.shade("alloy_border_pressed")},
	"alloy.disabled.surface": {"bg_color": T.color(&"surface"), "expand_margin_top": 0.0, "expand_margin_bottom": -4.0, "shadow_color": T.color(&"shadow", 0x88), "shadow_size": 3, "shadow_offset": Vector2(0, 4), "corner_radius_top_right": 9, "corner_radius_bottom_left": 9, "corner_detail": 1},
	"alloy.disabled.border": {"border_width_left": 3, "border_width_top": 1, "border_width_right": 1, "border_width_bottom": 1, "border_color": T.shade("alloy_border_disabled")},
	"emissive.resting.surface": {"bg_color": T.shade("emissive"), "expand_margin_top": 0.0, "expand_margin_bottom": -4.0, "shadow_color": T.color(&"shadow", 0x88), "shadow_size": 3, "shadow_offset": Vector2(0, 4), "corner_radius_top_right": 9, "corner_radius_bottom_left": 9, "corner_detail": 1},
	"emissive.resting.border": {"border_width_left": 3, "border_width_top": 1, "border_width_right": 1, "border_width_bottom": 1, "border_color": T.shade("emissive_border")},
	"emissive.hovered.surface": {"bg_color": T.color(&"accent_hover"), "expand_margin_top": 0.0, "expand_margin_bottom": -4.0, "shadow_color": T.color(&"shadow", 0x88), "shadow_size": 3, "shadow_offset": Vector2(0, 4), "corner_radius_top_right": 9, "corner_radius_bottom_left": 9, "corner_detail": 1},
	"emissive.hovered.border": {"border_width_left": 3, "border_width_top": 1, "border_width_right": 1, "border_width_bottom": 1, "border_color": T.shade("emissive_border_hovered")},
	"emissive.pressed.surface": {"bg_color": T.shade("emissive_pressed"), "expand_margin_top": -3.0, "expand_margin_bottom": -1.0, "shadow_color": T.color(&"shadow", 0x88), "shadow_size": 3, "shadow_offset": Vector2(0, 4), "corner_radius_top_right": 9, "corner_radius_bottom_left": 9, "corner_detail": 1},
	"emissive.pressed.border": {"border_width_left": 3, "border_width_top": 1, "border_width_right": 1, "border_width_bottom": 1, "border_color": T.shade("emissive_border_pressed")},
	"emissive.disabled.surface": {"bg_color": T.shade("emissive_disabled"), "expand_margin_top": 0.0, "expand_margin_bottom": -4.0, "shadow_color": T.color(&"shadow", 0x88), "shadow_size": 3, "shadow_offset": Vector2(0, 4), "corner_radius_top_right": 9, "corner_radius_bottom_left": 9, "corner_detail": 1},
	"emissive.disabled.border": {"border_width_left": 3, "border_width_top": 1, "border_width_right": 1, "border_width_bottom": 1, "border_color": T.shade("emissive_border_disabled")},
	"control.resting.padding": {"content_margin_left": 24.0, "content_margin_right": 24.0, "content_margin_top": 15.0, "content_margin_bottom": 19.0},
	"control.resting.padding.compact": {"content_margin_left": 24.0, "content_margin_right": 24.0, "content_margin_top": 6.0, "content_margin_bottom": 10.0},
	"control.hovered.padding": {"content_margin_left": 24.0, "content_margin_right": 24.0, "content_margin_top": 15.0, "content_margin_bottom": 19.0},
	"control.hovered.padding.compact": {"content_margin_left": 24.0, "content_margin_right": 24.0, "content_margin_top": 6.0, "content_margin_bottom": 10.0},
	"control.pressed.padding": {"content_margin_left": 24.0, "content_margin_right": 24.0, "content_margin_top": 18.0, "content_margin_bottom": 16.0},
	"control.pressed.padding.compact": {"content_margin_left": 24.0, "content_margin_right": 24.0, "content_margin_top": 9.0, "content_margin_bottom": 7.0},
	"control.disabled.padding": {"content_margin_left": 24.0, "content_margin_right": 24.0, "content_margin_top": 15.0, "content_margin_bottom": 19.0},
	"control.disabled.padding.compact": {"content_margin_left": 24.0, "content_margin_right": 24.0, "content_margin_top": 6.0, "content_margin_bottom": 10.0},
}

static func value(token: String) -> Variant:
	assert(VALUES.has(token), "Unknown Neon Circuit Material token: " + token)
	return VALUES[token]

## A native StyleBox's geometry with token colors; its own resource keeps no palette.
static func _tinted(source: StyleBoxFlat, fill: Color, border: Color) -> StyleBoxFlat:
	var box: StyleBoxFlat = source.duplicate()
	box.bg_color = fill
	box.border_color = border
	box.shadow_color = T.color(&"shadow")
	return box

static func _ruled(source: StyleBoxLine, ink: Color) -> StyleBoxLine:
	var line: StyleBoxLine = source.duplicate()
	line.color = ink
	return line

static func _static_init() -> void:
	VALUES.merge(T.materials())
	# Retain the alloy switch's geometry and travel with a distinct warning palette.
	var warning_colors := {
		"resting": [T.color(&"danger_surface"), T.shade("warning_border")],
		"hovered": [T.shade("warning_hovered"), T.shade("warning_border_hovered")],
		"pressed": [T.shade("warning_pressed"), T.shade("warning_border_pressed")],
		"disabled": [T.shade("warning_disabled"), T.shade("warning_border_disabled")],
	}
	for state in warning_colors:
		var surface: Dictionary = VALUES["alloy." + state + ".surface"].duplicate()
		var border: Dictionary = VALUES["alloy." + state + ".border"].duplicate()
		surface.bg_color = warning_colors[state][0]
		border.border_color = warning_colors[state][1]
		VALUES["warning." + state + ".surface"] = surface
		VALUES["warning." + state + ".border"] = border
	VALUES.merge(preload("settings_materials.gd").VALUES)
	VALUES.merge(preload("editor_materials.gd").materials(VALUES))
	VALUES.merge(preload("switch_materials.gd").materials(VALUES))
	VALUES.merge(preload("chronicle_materials.gd").materials(VALUES))
	VALUES.merge(preload("world_list_materials.gd").materials(VALUES))
	VALUES.merge(preload("hud_materials.gd").materials(VALUES))
	VALUES.merge(preload("arc_picker_materials.gd").materials(VALUES))
