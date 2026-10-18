extends GdUnitTestSuite

func test_fixed_frame_measured_choices_and_actions() -> void:
	var viewport: SubViewport = auto_free(SubViewport.new())
	viewport.size = Vector2i(1920, 1080)
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(viewport)
	var wizard := load("res://rookframe/ui/silkbound-ledger/components/surfaces/fullscreen_wizard.tscn").instantiate() as Control
	viewport.add_child(wizard)
	wizard.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var steps: Array[String] = ["Class", "Abilities", "Origin & Traits", "Equipment", "Identity", "Review"]
	wizard.configure("MÖRK BORG", "Create a character", steps)
	var choices := load("res://rookframe/ui/silkbound-ledger/components/data/paginated_choices.tscn").instantiate() as Control
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
	assert_bool(wizard.get_node(^"Layout/Footer").get_global_rect().end.y == 1044).is_true()
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
				assert_bool(row.get_node("Content/Row/Value").get_global_rect().end.x <= row.get_global_rect().end.x).is_true()
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
		var field := load("res://rookframe/ui/silkbound-ledger/components/forms/" + scene + ".tscn").instantiate() as Control
		wizard.get_stage_slot().add_child(field)
		await get_tree().process_frame
		await get_tree().process_frame
		assert_bool(field.get_node(^"Help").get_global_rect().end.y <= field.get_node(^"Editor").global_position.y).is_true()
		assert_bool(field.get_node(^"Editor").custom_minimum_size.y == (48 if scene == "task_text_field" else 152)).is_true()
		field.free()
	var summary := load("res://rookframe/ui/silkbound-ledger/components/data/summary_block.tscn").instantiate() as Control
	wizard.get_stage_slot().add_child(summary)
	var pairs: Array[Dictionary] = [{"label": "Name", "value": "Retained identity"}]
	summary.configure("Character", null, pairs)
	assert_bool(summary.get_node(^"Content/Rows").get_child(0).get_node(^"Inset/Row/Value").text == "Retained identity").is_true()
	for profile in [[Vector2i(844, 390), 18, 6], [Vector2i(1024, 768), 18, 2], [Vector2i(1920, 1080), 21, 8]]:
		viewport.size = profile[0]
		for frame in 5:
			await get_tree().process_frame
		var row := summary.get_node(^"Content/Rows").get_child(0)
		assert_int(row.get_node(^"Inset/Row/Value").get_theme_font_size("font_size")).is_equal(profile[1])
		assert_int(row.get_node(^"Inset").get_theme_constant("margin_top")).is_equal(profile[2])
		for choice in choices.get_node(^"Area/Rows").get_children():
			var value: Label = choice.get_node(^"Content/Row/Value")
			if choice.is_visible_in_tree() and value.text == "12":
				assert_int(value.get_theme_font_size("font_size")).is_equal(24 if profile[0].x == 1920 else 20)
				assert_float(value.size.x).is_greater_equal(value.get_theme_font("font").get_string_size("12", HORIZONTAL_ALIGNMENT_LEFT, -1, value.get_theme_font_size("font_size")).x)

	viewport.free()

func test_long_native_content_has_complete_readable_pages_and_retains_position() -> void:
	var viewport: SubViewport = auto_free(SubViewport.new())
	viewport.size = Vector2i(1024, 768)
	add_child(viewport)
	var pages = load("res://rookframe/ui/silkbound-ledger/components/data/paginated_content.tscn").instantiate()
	pages.size = Vector2(640, 380)
	var columns := HBoxContainer.new()
	columns.add_theme_constant_override("separation", 20)
	pages.get_node(^"Area").add_child(columns)
	for index in 1:
		var column := VBoxContainer.new()
		column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		columns.add_child(column)
		var summary = load("res://rookframe/ui/silkbound-ledger/components/data/summary_block.tscn").instantiate()
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

func test_step_badge_borders_survive_fractional_window_scaling(
	_do_skip := DisplayServer.get_name() == "headless",
	_skip_reason := "Border coverage requires the native renderer.") -> void:
	var viewport: SubViewport = auto_free(SubViewport.new())
	viewport.size_2d_override = Vector2i(1920, 1080)
	viewport.size_2d_override_stretch = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(viewport)
	var wizard := load("res://rookframe/ui/silkbound-ledger/components/surfaces/fullscreen_wizard.tscn").instantiate() as Control
	viewport.add_child(wizard)
	wizard.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var steps: Array[String] = ["Class", "Abilities", "Origin & Traits", "Equipment", "Identity", "Review"]
	wizard.configure("MÖRK BORG", "Create a character", steps)
	# Cover numbered, current and completed badges at native and fractional scales,
	# including the minimum desktop window and the reported missing-edge scale.
	for width in [1920, 1742, 1750, 1600, 1280]:
		viewport.size = Vector2i(width, roundi(width * 1080.0 / 1920.0))
		for current in [0, 4]:
			wizard.set_step(current)
			for frame in 6:
				await get_tree().process_frame
			RenderingServer.force_draw()
			var pixels := viewport.get_texture().get_image()
			var canvas_scale := Vector2(viewport.size) / Vector2(viewport.size_2d_override)
			for index in steps.size():
				var badge: Control = wizard.get_node(^"Layout/Steps/Row").get_child(index).get_node(^"Row/Marker")
				var rect := badge.get_global_rect()
				rect = Rect2(rect.position * canvas_scale, rect.size * canvas_scale)
				var border: Color = badge.get_theme_stylebox("panel").border_color
				for side in [SIDE_LEFT, SIDE_TOP, SIDE_RIGHT, SIDE_BOTTOM]:
					assert_bool(_badge_edge_visible(pixels, rect, border, side))\
						.override_failure_message("Step %d edge %d disappeared at width %d, current step %d" % [index + 1, side, width, current + 1]).is_true()
	viewport.free()

func _badge_edge_visible(pixels: Image, rect: Rect2, color: Color, side: int) -> bool:
	var vertical := side == SIDE_LEFT or side == SIDE_RIGHT
	var edge: float = (rect.position.x if side == SIDE_LEFT else rect.end.x) if vertical else (rect.position.y if side == SIDE_TOP else rect.end.y)
	var start: float = rect.position.y if vertical else rect.position.x
	var length: float = rect.size.y if vertical else rect.size.x
	# Check the middle half of each edge, excluding corners and the centred glyph.
	for along in range(ceili(start + length * 0.25), floori(start + length * 0.75)):
		var visible_pixel := false
		for across in range(floori(edge) - 2, ceili(edge) + 2):
			var pixel := pixels.get_pixel(across, along) if vertical else pixels.get_pixel(along, across)
			if absf(pixel.r - color.r) < 0.01 and absf(pixel.g - color.g) < 0.01 and absf(pixel.b - color.b) < 0.01:
				visible_pixel = true
		if not visible_pixel:
			return false
	return true
