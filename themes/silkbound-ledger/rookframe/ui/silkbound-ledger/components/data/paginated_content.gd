@tool
extends "res://rookframe/ui/components/data/paginated_content.gd"

@export var decorated_pager := false

func _style_pager() -> void:
	_range.add_theme_font_size_override("font_size", 15 if get_viewport_rect().size.y <= 560 else 18)
	if decorated_pager:
		_range.add_theme_color_override("font_color", Color("aebabe"))
		for button in [_previous, _next]:
			button.theme_type_variation = "WizardButton"
			button.text = ""
			button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
			button.icon = preload("res://rookframe/ui/icons/chevron-left.svg") if button == _previous else preload("res://rookframe/ui/icons/chevron-right.svg")
			button.accessibility_name = "Previous page" if button == _previous else "Next page"
			button.tooltip_text = button.accessibility_name
			for state in ["normal", "hover", "pressed", "disabled"]:
				var frame := button.get_theme_stylebox(state).duplicate() as StyleBoxFlat
				frame.content_margin_left = 0
				frame.content_margin_right = 0
				button.add_theme_stylebox_override(state, frame)


func _draw() -> void:
	if decorated_pager and content_inset_left > 0:
		draw_line(Vector2.ZERO,Vector2(0,size.y),Color("3e4346"))
