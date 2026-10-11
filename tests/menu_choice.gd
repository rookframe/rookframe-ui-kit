extends SceneTree
## Native input integration plus reproducible graphical evidence for both themes.
const Choice = preload("res://rookframe/ui/menu/MenuChoice.tscn")
const THEMES = [preload("res://rookframe/ui/menu/MenuTheme.tres"), preload("res://rookframe/ui/menu/cyberpunk/CyberpunkTheme.tres")]
var failures: Array[String] = []
var capture_dir := ""
var selection_events: Array[int] = []


func _initialize() -> void:
	call_deferred("verify")


func check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
		push_error(message)


func settle() -> void:
	for frame in range(5):
		await process_frame


func key(code: Key) -> void:
	var event := InputEventKey.new()
	event.keycode = code
	event.pressed = true
	# Route through the owning viewport so embedded Window input runs too.
	root.push_input(event)
	event = InputEventKey.new()
	event.keycode = code
	root.push_input(event)
	await settle()


func capture(name: String) -> void:
	if capture_dir.is_empty() or DisplayServer.get_name() == "headless":
		return
	await create_timer(0.15).timeout
	# Force one frame even when another Godot preview occludes this window.
	RenderingServer.force_draw(false)
	check(root.get_texture().get_image().save_png(capture_dir.path_join(name + ".png")) == OK, "Could not capture " + name)


func verify() -> void:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--capture-dir="):
			capture_dir = argument.trim_prefix("--capture-dir=")
	if not capture_dir.is_empty():
		DirAccess.make_dir_recursive_absolute(capture_dir)
	root.size = Vector2i(960, 640)
	root.content_scale_size = Vector2i(960, 640)
	root.gui_embed_subwindows = true
	if not capture_dir.is_empty():
		# Keep real desktop focus/pointer changes out of the automated input replay.
		root.unfocusable = true
		root.mouse_passthrough = true
	var screen := Control.new()
	root.add_child(screen)
	screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var backdrop := TextureRect.new()
	backdrop.texture = preload("res://rookframe/ui/menu/materials/textures/AI_generated_blackened_stone.png")
	backdrop.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	backdrop.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	backdrop.modulate = Color("737d76")
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	screen.add_child(backdrop)
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var choice := Choice.instantiate() as OptionButton
	screen.add_child(choice)
	choice.accessibility_name = "Language"
	choice.item_selected.connect(func(index: int) -> void: selection_events.append(index))
	for label in ["English", "Deutsch", "Français"]:
		choice.add_item(label)
	choice.set_item_metadata(1, "de")
	var menu := choice.get_popup()
	for theme_index in [0, 1, 0]:
		screen.theme = THEMES[theme_index]
		for compact in [false, true]:
			choice.set_compact(compact)
			await settle()
			choice.position = Vector2(280, 180)
			choice.size = Vector2(400, choice.get_theme_constant("minimum_height"))
			choice.select(0)
			choice.release_focus()
			await settle()
			var label := ("fantasy" if theme_index == 0 else "cyberpunk") + ("-compact" if compact else "-regular")
			await capture(label + "-closed")
			choice.grab_focus()
			await capture(label + "-focused")
			await key(KEY_ENTER)
			check(menu.visible, label + ": keyboard did not open the menu")
			check(menu.position.y >= choice.position.y + choice.size.y - choice.get_theme_constant("popup_overlap"), label + ": tray overlaps the trigger")
			check(menu.position.x == roundi(choice.position.x + choice.get_theme_constant("popup_inset")), label + ": tray inset is wrong")
			check(menu.size.x >= choice.size.x - 2 * choice.get_theme_constant("popup_inset"), label + ": tray width is wrong")
			if "--preview" in OS.get_cmdline_user_args():
				menu.set_focused_item(1)
				return
			await key(KEY_DOWN)
			check(menu.get_focused_item() == 1, label + ": arrow navigation failed")
			check(menu.is_item_checked(0) and not menu.is_item_checked(1), label + ": hover changed the selection")
			await capture(label + "-open")
			await key(KEY_ENTER)
			check(choice.selected == 1 and choice.get_selected_metadata() == "de", label + ": selection or metadata failed")
			check(not menu.visible and choice.has_focus(), label + ": selection did not close and return focus")
			choice.show_popup()
			await settle()
			await key(KEY_DOWN)
			await key(KEY_ESCAPE)
			check(choice.selected == 1 and not menu.visible, label + ": Escape changed the value")
			choice.disabled = true
			await settle()
			await capture(label + "-disabled")
			await key(KEY_ENTER)
			check(not menu.visible, label + ": disabled choice opened")
			choice.disabled = false
	# Regression: a height-only max_size used to collapse reopened menus to 1 px.
	for cycle in range(3):
		choice.grab_focus()
		await key(KEY_ENTER)
		check(menu.visible and menu.size.x >= 300, "Reopened tray collapsed after selection, cycle " + str(cycle))
		menu.set_focused_item(1 if choice.selected == 0 else 0)
		await key(KEY_ENTER)
		check(not menu.visible, "Repeated selection did not dismiss the tray")
	# Native disabled-item skipping and separators remain intact.
	choice.set_item_disabled(1, true)
	choice.select(0)
	choice.show_popup()
	await settle()
	menu.set_focused_item(0)
	await key(KEY_DOWN)
	check(menu.get_focused_item() == 2, "Keyboard did not skip disabled item")
	menu.hide()
	await settle()
	choice.set_item_disabled(1, false)
	# Selection is driven by native mouse input, not by emitting its signal.
	choice.show_popup()
	await settle()
	var row_height := menu.get_theme_font("font").get_height(menu.get_theme_font_size("font_size")) + menu.get_theme_constant("v_separation")
	var panel := menu.get_theme_stylebox("panel")
	var click := Vector2(menu.position) + Vector2(90, panel.get_content_margin(SIDE_TOP) + row_height * 1.5)
	var move := InputEventMouseMotion.new()
	move.position = click
	move.global_position = click
	root.push_input(move, true)
	await create_timer(0.35).timeout
	for pressed in [true, false]:
		var event := InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT
		event.position = click
		event.global_position = click
		event.pressed = pressed
		root.push_input(event, true)
	await settle()
	check(choice.selected == 1 and not menu.visible, "Pointer selection failed")
	# Dismissing outside must preserve the current selection and allow reopening.
	await settle()
	choice.show_popup()
	await settle()
	for pressed in [true, false]:
		var event := InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT
		event.position = Vector2(40, 40)
		event.global_position = event.position
		event.pressed = pressed
		root.push_input(event, true)
	await settle()
	check(not menu.visible and choice.selected == 1, "Outside dismissal changed the selection or left the popup open")
	# Long lists must open above a low trigger and remain scrollable in bounds.
	for index in range(40):
		choice.add_item("Language %02d" % index, 100 + index)
	choice.position.y = 540
	choice.select(40)
	choice.show_popup()
	await settle()
	check(menu.position.y >= 0 and menu.position.y + menu.size.y <= choice.position.y, "Long list is not bounded above trigger")
	check(menu.get_contents_minimum_size().y > menu.size.y, "Long list did not retain scrollable contents")
	await capture("fantasy-long-list")
	await key(KEY_UP)
	await key(KEY_ENTER)
	check(choice.selected == 39, "Scrolled selection failed")
	choice.show_popup()
	await settle()
	screen.theme = THEMES[1]
	await settle()
	check(not menu.visible, "Theme switch left a stale popup open")
	choice.clear()
	choice.add_item("العربية", 7)
	choice.add_item("עברית", 9)
	choice.layout_direction = Control.LAYOUT_DIRECTION_RTL
	choice.position = Vector2(280, 180)
	choice.size.x = 400
	choice.show_popup()
	await settle()
	check(menu.is_layout_rtl(), "Popup did not inherit RTL")
	await capture("cyberpunk-rtl")
	menu.hide()
	await settle()
	# Canvas scaling must preserve the connection between trigger and popup.
	choice.layout_direction = Control.LAYOUT_DIRECTION_LTR
	screen.theme = THEMES[0]
	screen.scale = Vector2(1.25, 1.25)
	choice.position = Vector2(100, 100)
	await settle()
	choice.show_popup()
	await settle()
	var transform := choice.get_screen_transform()
	var expected_left := transform.origin.x + choice.get_theme_constant("popup_inset") * transform.get_scale().x
	check(absf(menu.position.x - expected_left) <= 1, "Scaled popup lost its anchor")
	check(menu.size.y >= ceili(menu.get_contents_minimum_size().y * menu.content_scale_factor), "Scaled short list has an unnecessary scrollbar")
	await capture("fantasy-scaled")
	menu.hide()
	check(selection_events.size() == 11, "Selection emitted duplicate or missing signals: " + str(selection_events))
	screen.queue_free()
	await settle()
	print("MENU_CHOICE ", "PASS" if failures.is_empty() else failures)
	quit(0 if failures.is_empty() else 1)
