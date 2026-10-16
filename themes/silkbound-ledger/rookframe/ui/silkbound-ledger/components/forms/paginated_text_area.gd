extends "res://rookframe/ui/components/forms/paginated_text_area.gd"

func _style_editor() -> void:
	_editor.add_theme_font_size_override("font_size", 16 if compact else 20)
	_editor.add_theme_constant_override("line_spacing", 6 if compact else 10)
