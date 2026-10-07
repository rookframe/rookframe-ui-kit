extends GdUnitTestSuite

func test_fixed_frame_measured_choices_and_actions() -> void:
	var viewport: SubViewport = auto_free(SubViewport.new())
	viewport.size = Vector2i(1920, 1080)
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(viewport)
	var wizard := load("res://rookframe/ui/components/surfaces/fullscreen_wizard.tscn").instantiate() as Control
	viewport.add_child(wizard)
	wizard.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var steps: Array[String] = ["Class", "Abilities", "Origin & Traits", "Equipment", "Identity", "Review"]
	wizard.configure("MÖRK BORG", "Create a character", steps)
	var choices := load("res://rookframe/ui/components/data/paginated_choices.tscn").instantiate() as Control
	wizard.get_stage_slot().add_child(choices)
	var entries: Array[Dictionary] = []
	for index in 15:
		entries.append({"id": str(index), "title": "Choice %d" % (index + 1), "subtitle": "Retained result", "value": "12"})
	entries[4]["value"] = "A long resolved outcome remains within its row while the selected detail shows the full text"
	choices.configure(entries, "14", "RECORDED RESULTS", "15 / 15")
	for frame in 6:
		await get_tree().process_frame
	assert_bool(wizard.get_global_rect() == Rect2(0, 0, 1920, 1080)).is_true()
	assert_bool(wizard.get_context_slot().size.x == 336).is_true()
	assert_bool(wizard.get_node(^"Layout/Footer").get_global_rect().end.y == 1042).is_true()
	var seen: Array[String] = []
	var previous := choices.get_node(^"Pager/Previous") as Button
	while not previous.disabled:
		previous.pressed.emit()
	var next := choices.get_node(^"Pager/Next") as Button
	while true:
		await get_tree().process_frame
		for row in choices.get_node(^"Area/Rows").get_children():
			if row.visible:
				assert_bool(row.get_global_rect().end.y <= choices.get_node(^"Pager").global_position.y).is_true()
				assert_bool(row.get_node("Inset/Row/Value").get_global_rect().end.x <= row.get_global_rect().end.x).is_true()
				seen.append(row.accessibility_name)
		if next.disabled:
			break
		next.pressed.emit()
	assert_bool(seen.size() == 15).is_true()
	var action := []
	wizard.primary_requested.connect(func(): action.append("primary"))
	wizard.set_primary("Create character", false)
	wizard.get_node(^"Layout/Footer/Row/Primary").pressed.emit()
	assert_bool(action == ["primary"]).is_true()
	await get_tree().process_frame
	await get_tree().process_frame
	if DisplayServer.get_name() != "headless":
		RenderingServer.force_draw()
		for argument in OS.get_cmdline_user_args():
			if argument.begins_with("--capture="):
				viewport.get_texture().get_image().save_png(argument.trim_prefix("--capture="))
	wizard.set_primary("Rolling…", true)
	await get_tree().process_frame
	await get_tree().process_frame
	if DisplayServer.get_name() != "headless":
		RenderingServer.force_draw()
		for argument in OS.get_cmdline_user_args():
			if argument.begins_with("--capture="):
				viewport.get_texture().get_image().save_png(argument.trim_prefix("--capture=").get_basename() + "-disabled.png")
	for scene in ["task_text_field", "task_text_area"]:
		var field := load("res://rookframe/ui/components/forms/" + scene + ".tscn").instantiate() as Control
		wizard.get_stage_slot().add_child(field)
		await get_tree().process_frame
		await get_tree().process_frame
		assert_bool(field.get_node(^"Help").get_global_rect().end.y <= field.get_node(^"Editor").global_position.y).is_true()
		assert_bool(field.get_node(^"Editor").custom_minimum_size.y == (48 if scene == "task_text_field" else 152)).is_true()
		field.free()
	var summary := load("res://rookframe/ui/components/data/summary_block.tscn").instantiate() as Control
	wizard.get_stage_slot().add_child(summary)
	var pairs: Array[Dictionary] = [{"label": "Name", "value": "Retained identity"}]
	summary.configure("Character", null, pairs)
	assert_bool(summary.get_node(^"Content/Rows").get_child(0).get_node(^"Inset/Row/Value").text == "Retained identity").is_true()
	for profile in [[Vector2i(844, 390), 11, 5], [Vector2i(1024, 768), 12, 9], [Vector2i(1920, 1080), 16, 14]]:
		viewport.size = profile[0]
		for frame in 5:
			await get_tree().process_frame
		var row := summary.get_node(^"Content/Rows").get_child(0)
		assert_int(row.get_node(^"Inset/Row/Value").get_theme_font_size("font_size")).is_equal(profile[1])
		assert_int(row.get_node(^"Inset").get_theme_constant("margin_top")).is_equal(profile[2])
		for choice in choices.get_node(^"Area/Rows").get_children():
			var value: Label = choice.get_node(^"Inset/Row/Value")
			if choice.is_visible_in_tree() and value.text == "12":
				assert_int(value.get_theme_font_size("font_size")).is_equal(17 if profile[0].x == 1024 else 20)
				assert_float(value.size.x).is_greater_equal(value.get_theme_font("font").get_string_size("12", HORIZONTAL_ALIGNMENT_LEFT, -1, value.get_theme_font_size("font_size")).x)

	viewport.free()

func test_long_native_content_has_complete_readable_pages_and_retains_position() -> void:
	var viewport: SubViewport = auto_free(SubViewport.new())
	viewport.size = Vector2i(1024, 768)
	add_child(viewport)
	var pages = load("res://rookframe/ui/components/data/paginated_content.tscn").instantiate()
	pages.size = Vector2(640, 380)
	var columns := HBoxContainer.new()
	columns.add_theme_constant_override("separation", 20)
	pages.get_node(^"Area").add_child(columns)
	for index in 1:
		var column := VBoxContainer.new()
		column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		columns.add_child(column)
		var summary = load("res://rookframe/ui/components/data/summary_block.tscn").instantiate()
		column.add_child(summary)
	viewport.add_child(pages)
	var pairs: Array[Dictionary] = [{"label": "Origin", "value": "A long origin that wraps onto several lines in a narrow column."}, {"label": "Carried", "value": "Rope, lantern, oil, rations and a portable laboratory. ".repeat(12)}]
	columns.get_child(0).get_child(0).configure("Character", null, pairs, "A long description with all its text retained. ".repeat(80))
	for frame in 8:
		await get_tree().process_frame
	assert_bool(pages.get_node(^"Pager").visible).is_true()
	var readable := {}
	var labels := columns.find_children("*", "Label", true, false)
	var count := 0
	while true:
		var bounds: Rect2 = pages.get_node(^"Area").get_global_rect()
		for label in labels:
			if not label.is_visible_in_tree():
				continue
			for character in label.text.length():
				var rect: Rect2 = label.get_character_bounds(character)
				if not rect.has_area():
					continue
				rect.position += label.global_position
				if bounds.encloses(rect):
					readable[str(label.get_instance_id()) + ":" + str(character)] = true
		count += 1
		if pages.get_node(^"Pager/Next").disabled or count > 100:
			break
		pages.get_node(^"Pager/Next").pressed.emit()
	assert_int(count).is_greater(1)
	assert_int(count).is_less(100)
	for label in labels:
		if not label.is_visible_in_tree():
			continue
		for character in label.text.length():
			if label.get_character_bounds(character).has_area():
				assert_bool(readable.has(str(label.get_instance_id()) + ":" + str(character))).is_true()
	var retained: Dictionary = pages.capture_state()
	pages.restore_state({"page": 0})
	for frame in 3:
		await get_tree().process_frame
	assert_int(pages.capture_state().page).is_equal(0)
	pages.restore_state(retained)
	for frame in 3:
		await get_tree().process_frame
	assert_int(pages.capture_state().page).is_equal(retained.page)
	viewport.free()
