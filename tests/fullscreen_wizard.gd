extends SceneTree

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(1920, 1080)
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
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
	choices.configure(entries, "14", "RECORDED RESULTS", "15 / 15")
	for frame in 6:
		await process_frame
	assert(wizard.get_global_rect() == Rect2(0, 0, 1920, 1080))
	assert(wizard.get_context_slot().size.x == 400)
	assert(wizard.get_node(^"Layout/Footer").get_global_rect().end.y == 1080)
	var seen: Array[String] = []
	var previous := choices.get_node(^"Pager/Previous") as Button
	while not previous.disabled:
		previous.pressed.emit()
	var next := choices.get_node(^"Pager/Next") as Button
	while true:
		await process_frame
		for row in choices.get_node(^"Area/Rows").get_children():
			if row.visible:
				assert(row.get_global_rect().end.y <= choices.get_node(^"Pager").global_position.y)
				seen.append(row.accessibility_name)
		if next.disabled:
			break
		next.pressed.emit()
	assert(seen.size() == 15)
	var action := []
	wizard.primary_requested.connect(func(): action.append("primary"))
	wizard.set_primary("Create character", false)
	wizard.get_node(^"Layout/Footer/Row/Primary").pressed.emit()
	assert(action == ["primary"])
	if DisplayServer.get_name() != "headless":
		RenderingServer.force_draw()
		for argument in OS.get_cmdline_user_args():
			if argument.begins_with("--capture="):
				viewport.get_texture().get_image().save_png(argument.trim_prefix("--capture="))
	viewport.free()
	print("FULLSCREEN_WIZARD fixed frame, measured rows, retained selection and actions PASS")
	quit()
