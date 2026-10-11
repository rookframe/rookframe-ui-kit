extends SceneTree
## Standalone smoke check: native themes, recipes, live switching and layout.
const Catalogue = preload("res://examples/catalogue/visual_catalogue.tscn")
var failures: Array[String] = []


func _initialize() -> void:
	call_deferred("verify")


func check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
		push_error(message)


func settle() -> void:
	for frame in range(4):
		await process_frame


func verify() -> void:
	var screen := Catalogue.instantiate()
	root.add_child(screen)
	await settle()
	var primary: Button = screen.get_node("%Menu").get_node("Buttons/Surface/States/Normal/Viewport/Button")
	var surface: Panel = screen.get_node("%Menu").get_node("Surfaces/Record")
	var choice: OptionButton = screen.get_node("%Settings").get_node("Language/Choice")
	# Round-trip on the same instances catches stale texture/override state.
	for theme_index in [0, 1, 0]:
		screen.select_theme(theme_index)
		for compact in [false, true, false]:
			screen.set_compact(compact)
			await settle()
			_check_button_states(screen)
			var variant: StringName = &"menu_button_primary__compact" if compact else &"menu_button_primary"
			check(primary.theme_type_variation == variant, "Button density did not update")
			check(primary.get_node("Surface").visible == (theme_index == 1), "Theme retained the other button material")
			check(primary.get_node("Surface").texture == screen.theme.get_icon("cap", variant), "Button did not inherit theme artwork")
			check(primary.get_theme_font("font") == screen.theme.get_font("font", variant), "Button font does not match the theme")
			check(surface.get_node("Grain").texture == screen.theme.get_icon("grain", &"menu_world_record"), "Surface did not refresh its theme")
			check(choice.get_popup().theme_type_variation == &"settings_popup", "Popup lost its theme")
			for usage in [&"menu_button_primary", &"menu_button_standard", &"settings_choice", &"settings_action_primary", &"settings_action_secondary", &"settings_back", &"settings_navigation"]:
				for state in [&"normal", &"hover", &"pressed", &"hover_pressed", &"disabled", &"focus"]:
					check(screen.theme.has_stylebox(state, usage), "Missing %s/%s" % [usage, state])
		for page in range(3):
			screen.select_page(page)
			await settle()
			for candidate: Control in screen.get_node("%Pages").get_children():
				check(candidate.visible == (candidate.get_index() == page), "Catalogue page visibility is wrong")
		screen.select_page(1)
		choice.show_popup()
		await settle()
		check(choice.get_popup().visible, "Native choice popup did not open")
		check(choice.get_popup().get_theme_stylebox("panel") == screen.theme.get_stylebox("panel", &"settings_popup"), "Popup panel used fallback styling")
		choice.get_popup().hide()
	# Exercise real native keyboard input through the viewport.
	screen.select_page(0)
	await settle()
	primary.grab_focus()
	check(primary.has_focus(), "Native button could not take keyboard focus")
	var key := InputEventKey.new()
	key.keycode = KEY_ENTER
	key.pressed = true
	primary.get_viewport().push_input(key)
	key = InputEventKey.new()
	key.keycode = KEY_ENTER
	primary.get_viewport().push_input(key)
	await settle()
	check(screen.get_node("%Feedback").text == "Normal pressed.", "Native keyboard activation failed")
	primary.release_focus()
	for width in [800, 1440]:
		screen.size = Vector2(width, 900)
		await settle()
		check(screen.get_node("%Menu").vertical == (width < 1000), "Catalogue did not reflow")
		_check_button_states(screen)
	var capture_dir := ""
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--capture-dir="):
			capture_dir = argument.trim_prefix("--capture-dir=")
	if not capture_dir.is_empty() and DisplayServer.get_name() != "headless":
		DirAccess.make_dir_recursive_absolute(capture_dir)
		for theme_index in [0, 1]:
			screen.select_theme(theme_index)
			for page in range(3):
				screen.select_page(page)
				await settle()
				await create_timer(0.4).timeout
				await RenderingServer.frame_post_draw
				var path := "%s/%s-%s.png" % [capture_dir, "cyberpunk" if theme_index == 0 else "fantasy", page]
				check(root.get_texture().get_image().save_png(path) == OK, "Could not save " + path)
	screen.queue_free()
	await process_frame
	print("CURRENT_DESIGN_SYSTEM ", "PASS" if failures.is_empty() else failures)
	quit(0 if failures.is_empty() else 1)


func _check_button_states(screen: Control) -> void:
	var states := screen.get_node("%Menu").get_node("Buttons/Surface/States")
	for sample in states.get_children():
		var button: Button = sample.get_node("Viewport/Button")
		check(button.text == sample.name, "Button label does not describe its state")
		var expected: int = {
			"Normal": BaseButton.DRAW_NORMAL, "Hovered": BaseButton.DRAW_HOVER,
			"Pressed": BaseButton.DRAW_PRESSED, "Disabled": BaseButton.DRAW_DISABLED,
			"Focused": BaseButton.DRAW_NORMAL,
		}[str(sample.name)]
		check(button.get_draw_mode() == expected, "Wrong native draw state: " + str(sample.name))
		check(button.has_focus() == (sample.name == &"Focused"), "Wrong native focus state: " + str(sample.name))
		# The fully extended ornament and drop shadow must fit inside the preview.
		var travel := button.get_theme_constant("ornament_travel")
		var rect := button.get_rect()
		check(rect.position.x >= travel + 8 and sample.size.x - rect.end.x >= travel + 8, "Ornament can overflow the surface")
		check(rect.position.y >= 12 and sample.size.y - rect.end.y >= button.get_theme_constant("shadow_drop") + 4, "Depth can overflow the surface")
