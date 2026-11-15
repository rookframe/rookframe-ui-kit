@tool
extends RefCounted
## Concrete World list Materials, including every shared default.
const Geometry = preload("world_list_geometry.gd")
const Tokens = preload("res://rookframe/ui/themes/fantasy/tokens.gd")
## Semantic entries come from the Fantasy tokens; the panel lets 4% of the table through.
const PALETTE = {
	"panel": Color(Tokens.COLORS.surface_sunken, 245.0 / 255.0),
	"edge": Tokens.COLORS.border,
	"resting": Tokens.COLORS.surface_raised,
	"hover": Tokens.COLORS.surface_hover,
	"pressed": Tokens.COLORS.surface_pressed,
	"selected": Tokens.COLORS.accent_subtle,
	"selected_hover": Color("605638"),
	"selected_edge": Tokens.COLORS.border_strong,
	"focus": Tokens.COLORS.focus_ring,
	"online": Tokens.COLORS.success_content,
}

static func _box(fill: Color, border: Color) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = fill
	box.border_color = border
	box.set_border_width_all(Tokens.CONSTANTS.border_width)
	box.content_margin_left = 16.0
	box.content_margin_right = 16.0
	box.content_margin_top = 12.0
	box.content_margin_bottom = 12.0
	return box

static func materials(base: Dictionary) -> Dictionary:
	var values: Dictionary = Geometry.VALUES.duplicate()
	values["escape.surface_width"] = 540
	values["backdrop.color"] = Tokens.COLORS.scrim
	for compact in [false, true]:
		var suffix := ".compact" if compact else ""
		var surface: StyleBox = base["settings.surface" + suffix]
		var padding := StyleBoxEmpty.new()
		for side in 4:
			padding.set_content_margin(side, surface.get_content_margin(side))
		values["escape.padding" + suffix] = padding
	values["worlds.panel"] = _box(PALETTE.panel, PALETTE.edge)
	values["worlds.input"] = _box(PALETTE.resting, PALETTE.edge)
	values["worlds.input.disabled"] = _box(PALETTE.panel, PALETTE.edge)
	values["worlds.online"] = PALETTE.online
	values["worlds.selection"] = PALETTE.selected
	var focus := _box(Color.TRANSPARENT, PALETTE.focus)
	focus.draw_center = false
	focus.set_border_width_all(Tokens.CONSTANTS.focus_width)
	focus.set_expand_margin_all(-2.0)
	values["worlds.focus"] = focus
	for selected in [false, true]:
		for state in ["normal", "hover", "pressed", "hover_pressed", "disabled"]:
			var fill: Color = PALETTE.selected if selected else PALETTE.resting
			if state in ["hover", "hover_pressed"]:
				fill = PALETTE.selected_hover if selected else PALETTE.hover
			elif state == "pressed" and not selected:
				fill = PALETTE.pressed
			elif state == "disabled":
				fill = PALETTE.panel
			var face := _box(fill, PALETTE.selected_edge if selected else PALETTE.edge)
			if selected:
				face.border_width_left = 4
			values["worlds.row." + ("selected." if selected else "") + state] = face
	return values
