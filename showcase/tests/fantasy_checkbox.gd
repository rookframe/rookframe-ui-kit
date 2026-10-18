extends SceneTree
## Native input, live theme switching and rendered Fantasy Checkbox specimens.
const Scene = preload("res://rookframe/ui/components/forms/checkbox.tscn")
const Fantasy = preload("res://rookframe/ui/themes/fantasy/theme.tres")
const Catalogue = preload("res://examples/components/catalogue.tscn")
var failures: Array[String] = []
var assertions := 0
var capture_dir := ""
var preview := false

func _initialize() -> void:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--capture-dir="):
			capture_dir = argument.trim_prefix("--capture-dir=")
		preview = preview or argument == "--preview"
	if not capture_dir.is_empty(): DirAccess.make_dir_recursive_absolute(capture_dir)
	_run.call_deferred()

func check(condition: bool, message: String) -> void:
	assertions += 1
	if not condition:
		failures.append(message)
		push_error(message)

func settle() -> void:
	for frame in 6: await process_frame

func choice(parent: Node, title: String, selected := false) -> CheckBox:
	var control := Scene.instantiate() as CheckBox
	control.text = title
	control.button_pressed = selected
	parent.add_child(control)
	return control

func accept() -> void:
	for down in [true, false]:
		var event := InputEventKey.new()
		event.keycode = KEY_SPACE
		event.pressed = down
		root.push_input(event)
		await process_frame

func _run() -> void:
	root.size = Vector2i(1024, 768)
	root.content_scale_factor = 1.0
	var host := Control.new()
	host.theme = Fantasy
	root.add_child(host)
	host.size = root.size
	var control := choice(host, "Include session notes")
	var identity := control.get_instance_id()
	var events: Array[bool] = []
	control.toggled.connect(func(selected: bool): events.append(selected))
	await settle()
	var resting_size := control.get_combined_minimum_size()
	check(control.get_script() == null and control.get_child_count() == 0, "Checkbox stays a single stock CheckBox")
	check(resting_size.y >= 44, "Fantasy preserves the minimum target")
	control.grab_focus()
	await accept()
	check(control.button_pressed and events == [true], "Keyboard toggles exactly once")
	if DisplayServer.get_name() != "headless":
		root.grab_focus()
		root.warp_mouse(control.get_global_rect().get_center())
		await settle()
	var motion := InputEventMouseMotion.new()
	motion.position = control.get_global_rect().get_center()
	root.push_input(motion, true)
	for down in [true, false]:
		var click := InputEventMouseButton.new()
		click.button_index = MOUSE_BUTTON_LEFT
		click.position = control.get_global_rect().get_center()
		click.pressed = down
		root.push_input(click, true)
		await process_frame
	check(not control.button_pressed and events == [true, false], "The whole label is a native pointer target")
	for selected_theme in [null, Fantasy, load("res://rookframe/ui/themes/cyberpunk/theme.tres"), Fantasy]:
		host.theme = selected_theme
		await settle()
		check(control.get_instance_id() == identity and control.has_focus() and not control.button_pressed, "Theme changes retain identity, focus and value")
		var expected: Theme = ThemeDB.get_default_theme() if selected_theme == null else selected_theme
		if not expected.has_icon("checked", "CheckBox"): expected = ThemeDB.get_default_theme()
		check(control.get_theme_icon("checked") == expected.get_icon("checked", "CheckBox"), "Indicators follow the selected theme without stale overrides")
	await accept()
	control.disabled = true
	await accept()
	check(control.button_pressed and events == [true, false, true], "Disabled selected choices cannot activate")
	check(control.get_combined_minimum_size() == resting_size, "Selection and disabled changes do not shift layout")
	control.disabled = false
	control.layout_direction = Control.LAYOUT_DIRECTION_RTL
	await accept()
	check(not control.button_pressed, "RTL retains native activation")
	# Hosts own controller bindings; install one only for this input check.
	var binding := InputEventJoypadButton.new()
	binding.button_index = JOY_BUTTON_A
	InputMap.action_add_event("ui_accept", binding)
	for down in [true, false]:
		var event := InputEventJoypadButton.new()
		event.button_index = JOY_BUTTON_A
		event.pressed = down
		Input.parse_input_event(event)
		await process_frame
	check(control.button_pressed and events.size() == 5, "Controller acceptance toggles once")
	InputMap.action_erase_event("ui_accept", binding)
	host.free()
	if not preview:
		await capture_states()
	var catalogue = Catalogue.instantiate()
	root.add_child(catalogue)
	catalogue.select_theme("fantasy")
	catalogue.show_page("checkbox")
	if preview: return
	root.content_scale_factor = 1.0
	for canvas in [Vector2i(1920, 1080), Vector2i(1024, 768), Vector2i(844, 390)]:
		root.size = canvas
		catalogue.set_reduced_motion(true)
		await settle()
		var page = catalogue.current_page
		check(page.get_combined_minimum_size().x <= page.size.x + 1, "Checkbox page fits %s" % canvas)
		for checkbox in page.find_children("*", "CheckBox", true, false):
			check(checkbox.get_global_rect().end.x <= canvas.x + 1, "Long and RTL checkbox labels fit %s" % canvas)
		for index in page.section_blocks.size():
			var block: Control = page.section_blocks[index]
			catalogue.content_scroll.scroll_vertical += roundi(block.global_position.y - catalogue.content_scroll.global_position.y)
			await settle()
			await capture("catalogue-%dx%d-%d" % [canvas.x, canvas.y, index])
	catalogue.free()
	print("FANTASY_CHECKBOX: %d assertions; %d failures" % [assertions, failures.size()])
	quit(0 if failures.is_empty() else 1)

func capture_states() -> void:
	for canvas in [Vector2i(1920, 1080), Vector2i(1024, 768), Vector2i(844, 390)]:
		root.size = canvas
		for bright in [false, true]:
			var backdrop := ColorRect.new()
			backdrop.color = Color("ede7db") if bright else Color("171717")
			backdrop.size = canvas
			root.add_child(backdrop)
			var specimen := Control.new()
			specimen.theme = Fantasy
			specimen.position = (Vector2(canvas) - Vector2(800, 342)) / 2
			backdrop.add_child(specimen)
			var caption := Label.new()
			caption.text = "Fantasy · Checkbox · %d × %d" % [canvas.x, canvas.y]
			caption.add_theme_color_override("font_color", Color("30281f") if bright else Color("eee5d5"))
			specimen.add_child(caption)
			var button = preload("res://rookframe/ui/components/actions/button.tscn").instantiate()
			button.text = "Continue"
			button.compact = true
			button.reduced_motion = true
			button.position = Vector2(590, 0)
			button.size.x = 210
			specimen.add_child(button)
			var controls: Array[CheckBox] = []
			for index in 6:
				var control := choice(specimen, ["Unchecked", "Checked", "Hover", "Keyboard focus", "Disabled · unchecked", "Disabled · checked"][index], index % 2 == 1)
				control.position = Vector2((index % 2) * 410, 62 + (index / 2) * 56)
				control.size = Vector2(390, 44)
				control.disabled = index >= 4
				controls.append(control)
			var long_label := choice(specimen, "Include discovered locations and handwritten session notes", true)
			long_label.position = Vector2(0, 230)
			long_label.size = Vector2(800, 44)
			var translated := choice(specimen, "Сохранить заметки · Notizen speichern — RTL", true)
			translated.layout_direction = Control.LAYOUT_DIRECTION_RTL
			translated.position = Vector2(0, 286)
			translated.size = Vector2(800, 44)
			controls[3].grab_focus()
			var motion := InputEventMouseMotion.new()
			motion.position = controls[2].get_global_rect().get_center()
			if DisplayServer.get_name() != "headless": root.warp_mouse(motion.position)
			root.push_input(motion, true)
			await settle()
			check(controls[2].get_draw_mode() == BaseButton.DRAW_HOVER, "Hover specimen receives native pointer hover")
			for control in controls + [long_label, translated]:
				check(control.get_global_rect().end.x <= canvas.x and control.get_global_rect().end.y <= canvas.y, "States and translated labels fit %s" % canvas)
			await capture("states-%dx%d-%s" % [canvas.x, canvas.y, "light" if bright else "dark"])
			backdrop.free()
			await process_frame

func capture(filename: String) -> void:
	if capture_dir.is_empty() or DisplayServer.get_name() == "headless": return
	await RenderingServer.frame_post_draw
	check(root.get_texture().get_image().save_png(capture_dir.path_join(filename + ".png")) == OK, "Capture " + filename)
