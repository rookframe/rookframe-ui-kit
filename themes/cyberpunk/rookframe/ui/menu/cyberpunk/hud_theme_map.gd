@tool
extends RefCounted
## HUD semantic mappings: variation chains and Material references only.
## Concrete values live in materials/hud_materials.gd.
const EMPHASIS := {
	"components.button": "standard",
	"components.button.primary": "primary",
	"components.button.destructive": "destructive",
	"components.button.emblem": "emblem",
}
const FACE_SLOTS := ["normal", "hover", "pressed", "hover_pressed", "disabled", "focus"]
const BUTTON_SLOTS := ["normal", "hover", "pressed", "hover_pressed", "disabled"]
const INK := {"normal": "font_color", "hover": "font_hover_color", "pressed": "font_pressed_color", "hover_pressed": "font_hover_pressed_color", "disabled": "font_disabled_color"}
const ICON := {"normal": "icon_normal_color", "hover": "icon_hover_color", "pressed": "icon_pressed_color", "hover_pressed": "icon_hover_pressed_color", "disabled": "icon_disabled_color"}

static var ELEMENTS: Dictionary = {
	"RookframeHud": {"base_type": &"VBoxContainer", "constants/separation": "hud.attached.gap"},
	"RookframeHudBar": {"base_type": &"PanelContainer", "styles/panel": "hud.bar", "constants/separation": "hud.row.separation"},
	"RookframeHudBar@medium": {"base_type": &"RookframeHudBar", "styles/panel": "hud.bar.medium", "constants/separation": "hud.row.separation.medium"},
	"RookframeHudBar@compact": {"base_type": &"RookframeHudBar", "styles/panel": "hud.bar.compact", "constants/separation": "hud.row.separation.compact"},
	"RookframeHudAttached": {"base_type": &"PanelContainer", "styles/panel": "hud.attached"},
	"RookframeHudAttached@medium": {"base_type": &"RookframeHudAttached", "styles/panel": "hud.attached.medium"},
	"RookframeHudAttached@compact": {"base_type": &"RookframeHudAttached", "styles/panel": "hud.attached.compact"},
	"RookframeHudRule": {"base_type": &"VSeparator", "styles/separator": "hud.rule", "constants/separation": "hud.rule.separation"},
	"RookframeVital": {"base_type": &"ProgressBar", "styles/background": "hud.vital.track", "styles/fill": "hud.vital.fill"},
	"RookframeVitalWounded": {"base_type": &"RookframeVital", "styles/fill": "hud.vital.fill.wounded"},
	"RookframeVitalCritical": {"base_type": &"RookframeVital", "styles/background": "hud.vital.track.critical", "styles/fill": "hud.vital.fill.critical"},
	"RookframeVitalDepleted": {"base_type": &"RookframeVital", "styles/background": "hud.vital.track.depleted", "styles/fill": "hud.vital.fill.depleted"},
	"RookframeFavorite": {
		"base_type": &"CheckBox",
		"icons/checked": "hud.favorite.checked",
		"icons/unchecked": "hud.favorite.unchecked",
		"icons/checked_disabled": "hud.favorite.checked_disabled",
		"icons/unchecked_disabled": "hud.favorite.unchecked_disabled",
		"styles/normal": "hud.favorite.normal",
		"styles/hover": "hud.favorite.hover",
		"styles/pressed": "hud.favorite.pressed",
		"styles/hover_pressed": "hud.favorite.hover",
		"styles/disabled": "hud.favorite.normal",
		"styles/focus": "hud.favorite.focus",
	},
}


static func _static_init() -> void:
	for compact in [false, true]:
		var at := "@compact" if compact else ""
		var dot := ".compact" if compact else ""
		# Stacked tiles: X@stacked@compact -> X@stacked -> X -> its existing base.
		for usage in EMPHASIS:
			var kind: String = EMPHASIS[usage]
			var tile := {
				"base_type": StringName(usage + "@stacked") if compact else StringName(usage),
				"fonts/font": "hud.tile.font",
				"font_sizes/font_size": "hud.tile.font_size" + dot,
				"constants/icon_max_width": "hud.tile.icon" + dot,
				"constants/minimum_height": "hud.tile.height" + dot,
				"constants/h_separation": "hud.tile.h_separation",
			}
			for slot in FACE_SLOTS:
				tile["styles/" + slot] = "hud.tile." + kind + "." + slot + dot
			for slot in ["pressed", "hover_pressed"]:
				tile["colors/" + INK[slot]] = "hud.tile." + kind + ".ink." + slot
				tile["colors/" + ICON[slot]] = "hud.tile." + kind + ".ink." + slot
			ELEMENTS[usage + "@stacked" + at] = tile
		# Emblem: the most prominent emphasis, built on the primary action.
		var emblem := {
			"base_type": &"components.button.emblem" if compact else &"components.button.primary",
			"constants/icon_max_width": "hud.emblem.icon" + dot,
			"constants/minimum_height": "hud.tile.height" + dot,
		}
		for slot in BUTTON_SLOTS:
			emblem["styles/" + slot] = "hud.emblem." + slot + dot
			emblem["colors/" + INK[slot]] = "hud.signal.ink.disabled" if slot == "disabled" else "hud.emblem.icon_color"
			emblem["colors/" + ICON[slot]] = "hud.signal.ink.disabled" if slot == "disabled" else "hud.emblem.icon_color"
		emblem["styles/focus"] = "hud.emblem.focus" + dot
		emblem["colors/font_focus_color"] = "hud.emblem.icon_color"
		emblem["colors/icon_focus_color"] = "hud.emblem.icon_color"
		ELEMENTS["components.button.emblem" + at] = emblem
		# Identity plate: native Button faces whose content margins inset the copy.
		var identity := {
			"base_type": &"RookframeHudIdentity" if compact else &"Button",
			"constants/minimum_height": "hud.identity.height" + dot,
			"constants/copy_width": "hud.identity.copy_width" + dot,
		}
		for slot in FACE_SLOTS:
			identity["styles/" + slot] = "hud.identity." + slot + dot
		ELEMENTS["RookframeHudIdentity" + at] = identity
