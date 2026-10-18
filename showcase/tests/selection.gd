extends SceneTree
## The consolidated selection family retains content and state across Themes.
const Choice = preload("res://rookframe/ui/components/forms/choice.tscn")
const Select = preload("res://rookframe/ui/components/forms/select.tscn")
const THEMES = [null, preload("res://rookframe/ui/themes/silkbound-ledger/theme.tres"), preload("res://rookframe/ui/themes/fantasy/theme.tres"), preload("res://rookframe/ui/themes/cyberpunk/theme.tres")]
var failures: Array[String] = []
var capture_dir := ""
var events := 0

func _initialize() -> void:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--capture-dir="): capture_dir = argument.trim_prefix("--capture-dir=")
	if not capture_dir.is_empty(): DirAccess.make_dir_recursive_absolute(capture_dir)
	_run.call_deferred()

func check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
		push_error(message)

func settle() -> void:
	for frame in 8: await process_frame

func capture(name: String) -> void:
	if capture_dir.is_empty() or DisplayServer.get_name() == "headless": return
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(capture_dir.path_join(name + ".png"))

func key(code: Key) -> void:
	for down in [true, false]:
		var event := InputEventKey.new()
		event.keycode = code
		event.pressed = down
		root.push_input(event)
	await settle()

func _run() -> void:
	root.gui_embed_subwindows = true
	root.content_scale_factor = 1.0
	var scroll := ScrollContainer.new()
	root.add_child(scroll)
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	var stack := VBoxContainer.new()
	stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(stack)
	var choices: Array[Button] = []
	for variant in range(5):
		var choice = Choice.instantiate()
		choice.variant = variant
		choice.title = ["Travel style · Путешествие", "Guided exploration", "Campaign foundation", "Northern frontier", "Journey log"][variant]
		choice.description = "Long supporting copy remains readable when the available width changes. 旅の記録"
		choice.marker_text = "P"
		choice.action_label = "Include"
		choice.selected_label = "Included"
		choice.value_text = "12" if variant == 4 else ""
		choice.button_pressed = variant % 2 == 0
		choice.toggled.connect(func(_selected): events += 1)
		stack.add_child(choice)
		choices.append(choice)
	var disabled = Choice.instantiate()
	disabled.title = "Unavailable selection"
	disabled.description = "Selection remains visible while the choice is disabled."
	disabled.variant = disabled.Variant.CARD
	disabled.button_pressed = true
	disabled.disabled = true
	stack.add_child(disabled)
	var select = Select.instantiate()
	select.variant = select.Variant.MENU
	select.add_item("Northern frontier", 101)
	select.add_item("Silver harbour", 205)
	select.select(1)
	stack.add_child(select)
	for canvas in [Vector2i(1920,1080), Vector2i(1024,768), Vector2i(844,390)]:
		root.size = canvas
		for theme_index in THEMES.size():
			scroll.theme = THEMES[theme_index]
			for compact in [false, true]:
				RenderingServer.set_default_clear_color(Color("ededed") if compact else Color("202329"))
				for choice in choices: choice.compact = compact
				disabled.compact = compact
				select.compact = compact
				scroll.scroll_vertical = 0
				await settle()
				for index in choices.size():
					var choice = choices[index]
					check(choice.button_pressed == (index % 2 == 0), "Theme/density retains selection")
					check(choice.theme == null or choice.theme != THEMES[theme_index], "Presentation does not replace canonical owner")
					for child_path in ["Content/Row/Copy/Title", "Content/Row/Copy/Description", "Content/Row/State", "Content/Row/Value"]:
						var child: Control = choice.get_node(child_path)
						if child.visible:
							check(child.size.x > 0, "Visible content has width: " + child_path)
							check(choice.get_global_rect().grow(1).encloses(child.get_global_rect()), "Content fits choice: " + child_path)
				check(select.get_selected_id() == 205 and events == 0, "Presentation retains IDs without selection events")
				var name := "%dx%d-theme-%d-%s" % [canvas.x, canvas.y, theme_index, "compact" if compact else "regular"]
				await capture(name)
				scroll.scroll_vertical = int(scroll.get_v_scroll_bar().max_value)
				await settle()
				await capture(name + "-last")
	# Switching variants uses the same Button and restores theme presentation.
	var first = choices[0]
	scroll.scroll_vertical = 0
	first.grab_focus()
	for variant in [2, 1, 4, 0]:
		first.variant = variant
		await settle()
		check(first.has_focus() and first.button_pressed and events == 0, "Variant retains focus, identity and selection")
	# Exercise popup input through the consolidated Select, in the current host.
	scroll.scroll_vertical = int(scroll.get_v_scroll_bar().max_value)
	select.add_item("Eastern road", 306)
	select.select(0)
	select.set_item_disabled(1, true)
	var selected_ids: Array[int] = []
	select.item_selected.connect(func(index): selected_ids.append(select.get_item_id(index)))
	select.grab_focus()
	await key(KEY_ENTER)
	check(select.get_popup().visible, "Keyboard opens the Select menu")
	select.get_popup().set_focused_item(0)
	await key(KEY_DOWN)
	check(select.get_popup().get_focused_item() == 2, "Native navigation skips unavailable items")
	await key(KEY_ENTER)
	check(not select.get_popup().visible and selected_ids == [306], "Native popup selection emits one stable ID")
	check(select.has_focus(), "Closing the popup restores Select focus")
	await key(KEY_ENTER)
	check(select.get_popup().visible, "Select can reopen after selection")
	await capture("select-popup")
	await key(KEY_ESCAPE)
	check(not select.get_popup().visible and select.get_selected_id() == 306, "Dismissal retains selection")
	# Native pointer activation uses the same Choice as keyboard activation.
	scroll.scroll_vertical = 0
	await settle()
	root.notify_mouse_entered()
	var point := first.get_global_rect().get_center()
	var motion := InputEventMouseMotion.new()
	motion.position = point
	motion.global_position = point
	root.push_input(motion, true)
	for down in [true, false]:
		var event := InputEventMouseButton.new()
		event.position = point
		event.global_position = point
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = down
		root.push_input(event, true)
	await settle()
	check(not first.button_pressed and events == 1, "Pointer toggles the complete Choice once")
	scroll.free()
	print("SELECTION_THEMES: %d failures" % failures.size())
	quit(0 if failures.is_empty() else 1)
