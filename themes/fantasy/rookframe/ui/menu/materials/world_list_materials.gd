@tool
extends RefCounted
## Concrete World list Materials, including every shared default.
const Geometry = preload("world_list_geometry.gd")
const PALETTE = {
	"panel": Color("171c18f5"),
	"edge": Color("756443"),
	"resting": Color("252d27"),
	"hover": Color("394337"),
	"pressed": Color("1c241e"),
	"selected": Color("4c452b"),
	"selected_hover": Color("605638"),
	"focus": Color("e2c184"),
	"online": Color("c4d899"),
}

static func _box(fill: Color, border: Color) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = fill
	box.border_color = border
	box.set_border_width_all(1)
	box.content_margin_left = 16.0
	box.content_margin_right = 16.0
	box.content_margin_top = 12.0
	box.content_margin_bottom = 12.0
	return box

static func materials(base: Dictionary) -> Dictionary:
	var values: Dictionary = Geometry.VALUES.duplicate()
	values["escape.surface_width"] = 540
	values["backdrop.color"] = Color("030605dc")
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
	focus.set_border_width_all(2)
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
			var face := _box(fill, PALETTE.focus if selected else PALETTE.edge)
			if selected:
				face.border_width_left = 4
			values["worlds.row." + ("selected." if selected else "") + state] = face
	return values
