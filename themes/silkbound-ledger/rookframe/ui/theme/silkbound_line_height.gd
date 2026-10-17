extends RefCounted
const Appearance = preload("res://rookframe/ui/_internal/presentation/appearance.gd")
## Native font spacing for the approved Silkbound specimen line boxes.
static func apply(control: Control, multiplier: float) -> void:
	var source := control.get_theme_font("font")
	var font := source.duplicate() as FontVariation
	if font == null:
		font = FontVariation.new()
		Appearance.write(font, ^"base_font", source)
	Appearance.write(font, ^"spacing_top", 0)
	Appearance.write(font, ^"spacing_bottom", 0)
	var difference := roundi(control.get_theme_font_size("font_size") * multiplier) - ceili(font.get_height(control.get_theme_font_size("font_size")))
	Appearance.write(font, ^"spacing_top", floori(difference / 2.0))
	Appearance.write(font, ^"spacing_bottom", difference - font.spacing_top)
	Appearance.override_item(control, "fonts", "font", font)
	Appearance.override_item(control, "constants", "line_spacing", 0)
