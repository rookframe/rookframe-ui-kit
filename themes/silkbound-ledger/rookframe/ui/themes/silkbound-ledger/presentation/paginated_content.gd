@tool
extends RefCounted
const Appearance = preload("res://rookframe/ui/_internal/presentation/appearance.gd")





func _style_pager(control) -> void:
	Appearance.override_item(control._range, "font_sizes", "font_size", 15 if control.get_viewport_rect().size.y <= 560 else 18)
	if control.decorated_pager:
		Appearance.override_item(control._range, "colors", "font_color", Color("aebabe"))
		for button in [control._previous, control._next]:
			Appearance.write(button, ^"theme_type_variation", "WizardButton")
			Appearance.write(button, ^"text", "")
			Appearance.write(button, ^"icon_alignment", HORIZONTAL_ALIGNMENT_CENTER)
			Appearance.write(button, ^"icon", preload("res://rookframe/ui/icons/chevron-left.svg") if button == control._previous else preload("res://rookframe/ui/icons/chevron-right.svg"))
			Appearance.write(button, ^"accessibility_name", "Previous page" if button == control._previous else "Next page")
			Appearance.write(button, ^"tooltip_text", button.accessibility_name)
			for state in ["normal", "hover", "pressed", "disabled"]:
				var frame = button.get_theme_stylebox(state).duplicate() as StyleBoxFlat
				Appearance.write(frame, ^"content_margin_left", 0)
				Appearance.write(frame, ^"content_margin_right", 0)
				Appearance.override_item(button, "styles", state, frame)

func _draw(control) -> void:
	if control.decorated_pager and control.content_inset_left > 0:
		control.draw_line(Vector2.ZERO,Vector2(0,control.size.y),Color("3e4346"))
