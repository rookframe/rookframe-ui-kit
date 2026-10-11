@tool
extends RefCounted
## Virtual display surfaces: crisp cyan signals and translucent blue fields.
static func materials(settings: Dictionary) -> Dictionary:
	var values := {
		"choice.font": preload("ui.tres"),
		"choice.ink": Color("c4d5df"),
		"choice.ink.hover": Color("e9ffff"),
		"choice.ink.disabled": Color("8199a5"),
		"choice.outline": Color.TRANSPARENT,
		"choice.outline_size": 0,
		"choice.arrow": preload("settings_arrow.svg"),
		"choice.check": preload("choice_check.svg"),
		"choice.blank": settings["settings.blank"],
		"choice.modulate_arrow": 1,
		"choice.selection_disabled": Color("8199a5"),
		"choice.selection_inset": 18,
		"choice.popup_inset": 0,
		"choice.popup_inset.compact": 0,
		"choice.popup_overlap": 0,
		"choice.popup_overlap.compact": 0,
		"choice.font_size": 20,
		"choice.font_size.compact": 18,
		"choice.height": 52,
		"choice.height.compact": 48,
		"choice.arrow_margin": 16,
		"choice.arrow_margin.compact": 16,
		"choice.copy_gap": 12,
		"choice.popup_gap": 20,
		"choice.popup_gap.compact": 14,
		"choice.popup_start": 8,
		"choice.popup_start.compact": 8,
		"choice.popup_end": 48,
		"choice.popup_h_gap": 0,
	}
	for compact in [false, true]:
		var suffix := ".compact" if compact else ""
		for state in ["normal", "hover", "pressed", "hover_pressed", "disabled", "focus"]:
			values["choice." + state + suffix] = settings["settings.control." + state]
	var panel: StyleBoxFlat = settings["settings.popup"].duplicate()
	panel.bg_color = Color("0d1b27fa")
	panel.shadow_color = Color("00000080")
	panel.shadow_size = 6
	panel.shadow_offset = Vector2(0, 4)
	values["choice.popup"] = panel
	var hover := StyleBoxFlat.new()
	hover.bg_color = Color("244f6099")
	hover.border_color = Color("81e7e8")
	hover.border_width_left = 2
	values["choice.popup_hover"] = hover
	return values
