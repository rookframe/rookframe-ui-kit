extends RefCounted
## HUD and Button layout mappings: semantic selectors and Material references only.
## Each published variation declares its base so Godot resolves the full chain:
## `X__stacked__compact` -> `X__stacked` -> `X` -> the compiled base of X.
static var ELEMENTS := _elements()

const BUTTONS = [&"components_button", &"components_button_primary", &"components_button_destructive", &"components_button_emblem"]
const INK_SLOTS = {
	"font_hover_color": "hud.tile.ink.hover",
	"font_pressed_color": "hud.tile.ink.selected",
	"font_hover_pressed_color": "hud.tile.ink.selected",
	"font_focus_color": "hud.tile.ink.hover",
	"icon_hover_color": "hud.tile.ink.hover",
	"icon_pressed_color": "hud.tile.ink.selected",
	"icon_hover_pressed_color": "hud.tile.ink.selected",
	"icon_focus_color": "hud.tile.ink.hover",
}


static func _elements() -> Dictionary:
	var elements := {
		# EMBLEM: the most prominent emphasis, a primary square casing with its brass leaves.
		"components_button_emblem": _button(&"components_button_primary", "emblem", ""),
		"components_button_emblem__compact": _button(&"components_button_emblem", "emblem", ".compact"),
		"RookframeHudBar": {"base_type": &"PanelContainer", "styles/panel": "hud.bar.panel", "constants/separation": "hud.bar.separation"},
		"RookframeHudBar__medium": {"base_type": &"RookframeHudBar", "styles/panel": "hud.bar.panel.medium", "constants/separation": "hud.bar.separation.medium"},
		"RookframeHudBar__compact": {"base_type": &"RookframeHudBar", "styles/panel": "hud.bar.panel.compact", "constants/separation": "hud.bar.separation.compact"},
		"RookframeHudAttached": {"base_type": &"PanelContainer", "styles/panel": "hud.attached.panel"},
		"RookframeHudAttached__medium": {"base_type": &"RookframeHudAttached", "styles/panel": "hud.attached.panel.medium"},
		"RookframeHudAttached__compact": {"base_type": &"RookframeHudAttached", "styles/panel": "hud.attached.panel.compact"},
		"RookframeHudRule": {"base_type": &"VSeparator", "styles/separator": "hud.rule", "constants/separation": "hud.rule.separation"},
		"RookframeHudIdentity": _identity(""),
		"RookframeHudIdentity__compact": _identity(".compact"),
		"RookframeVital": {"base_type": &"ProgressBar", "styles/background": "hud.vital.track", "styles/fill": "hud.vital.steady"},
		"RookframeVitalWounded": {"base_type": &"RookframeVital", "styles/fill": "hud.vital.wounded"},
		"RookframeVitalCritical": {"base_type": &"RookframeVital", "styles/fill": "hud.vital.critical"},
		"RookframeVitalDepleted": {"base_type": &"RookframeVital", "styles/background": "hud.vital.track.depleted", "styles/fill": "hud.vital.empty"},
		"RookframeFavorite": {
			"base_type": &"CheckBox",
			"constants/h_separation": "hud.favorite.gap",
			"colors/checkbox_checked_color": "hud.white",
			"colors/checkbox_unchecked_color": "hud.white",
			"icons/checked": "hud.favorite.checked",
			"icons/unchecked": "hud.favorite.unchecked",
			"icons/checked_disabled": "hud.favorite.checked.disabled",
			"icons/unchecked_disabled": "hud.favorite.unchecked.disabled",
			"styles/normal": "hud.favorite.normal",
			"styles/hover": "hud.favorite.hover",
			"styles/pressed": "hud.favorite.pressed",
			"styles/hover_pressed": "hud.favorite.hover_pressed",
			"styles/disabled": "hud.favorite.disabled",
			"styles/focus": "hud.favorite.focus",
		},
	}
	# STACKED: square walnut tiles on the same carved presentation as inline Buttons.
	for usage in BUTTONS:
		var emphasis := String(usage).trim_prefix("components_button").trim_prefix("_")
		var stacked := StringName(String(usage) + "__stacked")
		elements[stacked] = _button(usage, emphasis, "", true)
		elements[StringName(String(stacked) + "__compact")] = _button(stacked, emphasis, ".compact", true)
	return elements


static func _button(base: StringName, emphasis: String, density: String, stacked := false) -> Dictionary:
	var face := "hud.tile" if stacked else "hud.emblem"
	var element := {
		"base_type": base,
		"icons/cap": "wood.plain.cap",
		"constants/patch_side": "wood.plain.patch_side",
		"constants/patch_rail": "wood.plain.patch_rail",
		"constants/art_height": "hud.tile.art_height" + density,
		"constants/minimum_height": face + ".minimum_height" + density,
		"constants/icon_max_width": face + ".icon_max_width" + density,
		"font_sizes/font_size": "hud.tile.font_size" + density if stacked else "button.compact.font_size" if density else "button.standard.font_size",
		# Focus is a brass ring on the casing, distinct from hover light and selection.
		"styles/focus": face + ".focus" + ("" if stacked else density),
	}
	for slot in ["normal", "hover", "pressed", "hover_pressed", "disabled"]:
		element["styles/" + slot] = face + "." + slot + density
	if emphasis in ["primary", "emblem"]:
		# A lone EMBLEM shows the primary's cast leaves beside its casing. Leaves need
		# clearance that a wrapping label cannot measure, so stacked tiles and compact
		# density light the casing at rest instead.
		var leaves := not stacked and density.is_empty()
		for item in ["width", "height", "travel"]:
			element["constants/ornament_" + item] = "hud.emblem.leaf." + item if leaves else "hud.leaf.none"
		element["constants/ornament_rest"] = "hud.emblem.leaf.rest"
		if stacked:
			element["colors/rest_tint"] = "wood.cap.tint"
			element["colors/cap_tint"] = "hud.primary.cap_tint"
			element["colors/font_color"] = "hud.tile.ink.hover"
			element["colors/icon_normal_color"] = "hud.tile.ink.hover"
	if stacked and emphasis != "destructive":
		element["colors/selected_tint"] = "hud.tile.selected_tint"
		for item in INK_SLOTS:
			element["colors/" + item] = INK_SLOTS[item]
	return element

static func _identity(density: String) -> Dictionary:
	var element := {"base_type": &"Button" if density.is_empty() else &"RookframeHudIdentity", "styles/focus": "hud.identity.focus" + density}
	if not density.is_empty():
		element["constants/copy_width"] = "hud.identity.copy_width" + density
	for slot in ["normal", "hover", "pressed", "hover_pressed", "disabled"]:
		element["styles/" + slot] = "hud.identity." + slot + density
	return element
