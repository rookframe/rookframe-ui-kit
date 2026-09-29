extends GdUnitTestSuite

func test_fixed_frame_measured_choices_and_actions() -> void:
	var display := load("res://rookframe/ui/theme/task_display.tres") as FontVariation
	var wordmark := load("res://rookframe/ui/theme/task_wordmark.tres") as FontVariation
	assert_bool(wordmark.get_string_size("MÖRK BORG", HORIZONTAL_ALIGNMENT_LEFT, -1, 22).x > display.get_string_size("MÖRK BORG", HORIZONTAL_ALIGNMENT_LEFT, -1, 22).x).is_true()
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
	assert_bool(wizard.get_context_slot().size.x == 400).is_true()
	assert_bool(wizard.get_node(^"Layout/Footer").get_global_rect().end.y == 1079).is_true()
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
		assert_bool(field.get_node(^"Help").get_index() < field.get_node(^"Editor").get_index()).is_true()
		assert_bool(field.get_node(^"Editor").custom_minimum_size.y == (48 if scene == "task_text_field" else 152)).is_true()
		field.free()
	var summary := load("res://rookframe/ui/components/data/summary_block.tscn").instantiate() as Control
	wizard.get_stage_slot().add_child(summary)
	var pairs: Array[Dictionary] = [{"label": "Name", "value": "Retained identity"}]
	summary.configure("Character", null, pairs)
	assert_bool(summary.get_node(^"Content/Rows").get_child(0).get_node(^"Inset/Row/Value").text == "Retained identity").is_true()
	viewport.free()
