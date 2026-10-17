extends RefCounted
## Neutral authoring chrome, separate from the production specimen Theme.

static func create(dark: bool = false) -> Theme:
	var result := Theme.new()
	result.default_font_size = 16
	var ink := Color("ededed") if dark else Color("202023")
	var paper := Color("171719") if dark else Color("fafafa")
	var line := Color("38383c") if dark else Color("dedee2")
	var hover := Color("2d2d31") if dark else Color("efeff1")
	result.set_color("font_color", "Label", ink)
	result.set_color("font_color", "Button", ink)
	result.set_color("font_hover_color", "Button", ink)
	result.set_color("font_pressed_color", "Button", ink)
	result.set_color("font_focus_color", "Button", ink)
	result.set_color("font_disabled_color", "Button", Color("85858c"))
	result.set_stylebox("normal", "Button", box(paper, line, 10))
	result.set_stylebox("hover", "Button", box(hover, line, 10))
	result.set_stylebox("pressed", "Button", box(hover, Color("909099"), 10))
	result.set_stylebox("disabled", "Button", box(paper, line, 10))
	var focus := box(Color.TRANSPARENT, Color("9682e8"), 10)
	focus.set_border_width_all(2)
	result.set_stylebox("focus", "Button", focus)
	result.set_type_variation("ShowcaseNav", "Button")
	result.set_stylebox("normal", "ShowcaseNav", box(Color.TRANSPARENT, Color.TRANSPARENT, 10))
	result.set_stylebox("pressed", "ShowcaseNav", box(hover, Color.TRANSPARENT, 10))
	result.set_type_variation("ShowcaseBackground", "PanelContainer")
	result.set_stylebox("panel", "ShowcaseBackground", box(paper, Color.TRANSPARENT, 0))
	result.set_type_variation("ShowcaseExample", "PanelContainer")
	result.set_stylebox("panel", "ShowcaseExample", box(Color("15191a"), line, 24))
	result.set_color("font_color", "LineEdit", ink)
	result.set_color("font_placeholder_color", "LineEdit", Color("85858c"))
	result.set_stylebox("normal", "LineEdit", box(paper, line, 12))
	result.set_stylebox("focus", "LineEdit", focus)
	result.set_constant("separation", "VBoxContainer", 10)
	result.set_constant("separation", "HBoxContainer", 12)
	result.set_stylebox("separator", "HSeparator", box(line, line, 0))
	return result

static func box(fill: Color, border: Color, padding: int) -> StyleBoxFlat:
	var result := StyleBoxFlat.new()
	result.bg_color = fill
	result.border_color = border
	result.set_border_width_all(1)
	result.set_corner_radius_all(6)
	result.content_margin_left = padding
	result.content_margin_right = padding
	result.content_margin_top = padding
	result.content_margin_bottom = padding
	return result
