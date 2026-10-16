extends GdUnitTestSuite

func test_returned_focus_keeps_primary_action_readable() -> void:
	var button: Button = auto_free(Button.new())
	button.theme = load("res://rookframe/ui/theme/silkbound_theme.tres")
	button.theme_type_variation = "TaskPrimary"
	button.text = "Roll Strength"
	button.custom_minimum_size = Vector2(180, 44)
	add_child(button)
	for attempt in 2:
		button.show()
		button.grab_focus()
		await get_tree().process_frame
		assert_bool(button.has_focus()).is_true()
		for item in ["font_focus_color", "font_hover_pressed_color", "icon_focus_color", "icon_hover_pressed_color"]:
			assert_float(button.get_theme_color(item).get_luminance()).override_failure_message("Primary action must keep dark text and icons after focus returns: " + item).is_less(0.2)
		button.hide()
