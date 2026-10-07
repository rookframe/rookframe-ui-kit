extends RefCounted
## Native font spacing for the approved Silkbound specimen line boxes.
static func apply(control: Control, multiplier: float) -> void:
	var source := control.get_theme_font("font")
	var font := source.duplicate() as FontVariation
	if font == null:
		font = FontVariation.new()
		font.base_font = source
	font.spacing_top = 0
	font.spacing_bottom = 0
	var difference := roundi(control.get_theme_font_size("font_size") * multiplier) - ceili(font.get_height(control.get_theme_font_size("font_size")))
	font.spacing_top = floori(difference / 2.0)
	font.spacing_bottom = difference - font.spacing_top
	control.add_theme_font_override("font", font)
	control.add_theme_constant_override("line_spacing", 0)
