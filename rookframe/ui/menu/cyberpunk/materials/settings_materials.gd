@tool
extends RefCounted
## Concrete Settings Materials. Stock StyleBoxes keep layout and hit bounds together.
const Geometry = preload("../../materials/settings_geometry.gd")
const PALETTE = {
	"secondary": Color("adc3cd"),
	"surface": Color("0d1b27f5"),
	"edge": Color("416978"),
	"normal": Color("152f3e"),
	"hover": Color("244f60"),
	"pressed": Color("102633"),
	"disabled_bg": Color("182a34"),
	"disabled": Color("8199a5"),
	"accent": Color("81e7e8"),
	"primary": Color("60ccce"),
	"primary_hover": Color("99eded"),
	"primary_pressed": Color("459fa9"),
	"primary_ink": Color("09232d"),
	"danger": Color("ff918c"),
	"rule": Color("41606c"),
}
static var VALUES: Dictionary = _materials()

static func _box(fill: Color, border: Color, padding: float = 16.0) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = fill
	box.border_color = border
	box.set_border_width_all(1)
	box.content_margin_left = padding
	box.content_margin_right = padding
	box.content_margin_top = 10.0
	box.content_margin_bottom = 10.0
	return box

static func _materials() -> Dictionary:
	var values: Dictionary = Geometry.VALUES.duplicate()
	values["settings.secondary"] = PALETTE.secondary
	values["settings.danger"] = PALETTE.danger
	values["settings.disabled"] = PALETTE.disabled
	values["settings.primary.ink"] = PALETTE.primary_ink
	values["settings.modulate_arrow"] = 1
	values["settings.arrow"] = preload("settings_arrow.svg")
	values["settings.checked"] = preload("settings_checked.svg")
	values["settings.unchecked"] = preload("settings_unchecked.svg")
	var blank := GradientTexture2D.new()
	blank.width = 1
	blank.height = 1
	blank.gradient = Gradient.new()
	blank.gradient.colors = PackedColorArray([Color.TRANSPARENT, Color.TRANSPARENT])
	values["settings.blank"] = blank
	for compact in [false, true]:
		var panel := _box(PALETTE.surface, PALETTE.edge, 20.0 if compact else 36.0)
		panel.content_margin_top = 16.0 if compact else 28.0
		panel.content_margin_bottom = panel.content_margin_top
		panel.border_width_top = 3
		panel.border_width_bottom = 3
		panel.shadow_color = Color(0, 0, 0, 0.6)
		panel.shadow_size = 12
		panel.shadow_offset = Vector2(0, 6)
		values["settings.surface" + (".compact" if compact else "")] = panel
	for kind in ["control", "primary", "quiet"]:
		for state in ["normal", "hover", "pressed", "hover_pressed", "disabled"]:
			var key: String = "pressed" if state == "hover_pressed" else state
			var fill: Color = PALETTE.normal
			var edge: Color = PALETTE.edge
			if key == "hover": fill = PALETTE.hover
			if key == "pressed": fill = PALETTE.pressed
			if kind == "primary":
				fill = PALETTE.primary_hover if key == "hover" else PALETTE.primary_pressed if key == "pressed" else PALETTE.primary
				edge = PALETTE.accent
			if key == "disabled":
				fill = PALETTE.disabled_bg
				edge = PALETTE.rule
			if kind == "quiet" and key == "normal": fill = Color.TRANSPARENT
			var face := _box(fill, edge)
			if kind == "quiet": face.set_border_width_all(0)
			else: face.border_width_bottom = 3 if key != "pressed" else 1
			if key == "pressed":
				face.content_margin_top = 12.0
				face.content_margin_bottom = 8.0
			values["settings." + kind + "." + state] = face
		var focus := _box(Color.TRANSPARENT, PALETTE.accent)
		focus.draw_center = false
		focus.set_border_width_all(2)
		values["settings." + kind + ".focus"] = focus
	values["settings.popup"] = _box(PALETTE.surface, PALETTE.accent, 8.0)
	var rule := StyleBoxLine.new()
	rule.color = PALETTE.rule
	rule.thickness = 1
	values["settings.rule"] = rule
	for key in ["track", "grabber", "hover", "pressed"]:
		var fill: Color = PALETTE.pressed if key == "track" else PALETTE.accent if key == "hover" else PALETTE.primary_pressed if key == "pressed" else PALETTE.edge
		var bar := _box(fill, Color.TRANSPARENT, 6.0)
		bar.content_margin_top = 6.0
		bar.content_margin_bottom = 6.0
		values["settings.scroll." + key] = bar
	return values
