extends GdUnitTestSuite

func test_fifteen_miniatures_paginate_and_retain_selection_at_all_canvases() -> void:
	for profile in [[Vector2i(844, 390), 3], [Vector2i(1024, 768), 6], [Vector2i(1920, 1080), 8]]:
		var viewport: SubViewport = auto_free(SubViewport.new())
		viewport.size = profile[0]
		viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		add_child(viewport)
		var browser = load("res://rookframe/ui/components/content/fullscreen_miniature_browser.tscn").instantiate()
		viewport.add_child(browser)
		browser.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		var entries: Array[Dictionary] = []
		var previews: Array[Control] = []
		for index in range(15):
			entries.append({"id": str(index), "title": "Goblin " + str(index + 1), "package": "MÖRK BORG" if index < 12 else "Other Package", "available": true})
		browser.preview_requested.connect(func(_entry, target): previews.append(target))
		browser.configure(entries, "0")
		await _settle()
		assert_bool(previews.size() == 15).is_true()
		await _capture(viewport, "browser-" + str(viewport.size.x))
		var rows: GridContainer = browser.get_node("Layout/Results/Content/GridArea/Rows")
		var next: Button = browser.get_node("Layout/Results/Content/Pager/Next")
		var seen: Array[String] = []
		while true:
			var visible := 0
			for row in rows.get_children():
				if row.visible:
					visible += 1
					assert_bool(not seen.has(row.accessibility_name)).is_true()
					seen.append(row.accessibility_name)
					assert_bool(row.get_global_rect().end.y <= next.get_global_rect().position.y).is_true()
					assert_bool(row.get_global_rect().end.x <= viewport.size.x).is_true()
			assert_bool(visible == mini(profile[1], 15 - seen.size() + visible)).is_true()
			if next.disabled:
				break
			next.pressed.emit()
			await _settle()
		assert_bool(seen.size() == 15).is_true()
		assert_bool(browser.selection().id == "0").is_true()
		var search: LineEdit = browser.get_node("Layout/SearchArea/Content/Search")
		search.text = "Other Package"
		search.text_changed.emit(search.text)
		await _settle()
		assert_bool(rows.get_children().filter(func(row): return row.visible).size() == 3).is_true()
		assert_bool(browser.selection().id == "0").is_true()
		assert_bool(not browser.get_node("Layout/Footer/Row/Choose").disabled).is_true()
		rows.get_child(14).pressed.emit()
		assert_bool(browser.selection().id == "14").is_true()
		var actions := {"choose": 0, "cancel": 0, "close": 0}
		browser.choose_requested.connect(func(entry): assert_str(str(entry.id)).is_equal("14"); actions.choose += 1)
		browser.cancel_requested.connect(func(): actions.cancel += 1)
		browser.close_requested.connect(func(): actions.close += 1)
		browser.get_node("Layout/Footer/Row/Choose").pressed.emit()
		browser.get_node("Layout/Footer/Row/Cancel").pressed.emit()
		browser.get_node("Layout/Header/Row/Close").pressed.emit()
		assert_bool(actions == {"choose": 1, "cancel": 1, "close": 1}).is_true()
		assert_bool(browser.selection().id == "14").is_true()
		search.text = "no such miniature"
		search.text_changed.emit(search.text)
		await _settle()
		assert_bool(browser.get_node("Layout/Results/Content/State").visible).is_true()
		assert_bool(browser.selection().id == "14").is_true()
		browser.set_state("loading")
		assert_bool(browser.get_node("Layout/Footer/Row/Choose").disabled).is_true()
		browser.set_state("error", "Could not load miniatures")
		assert_bool(browser.get_node("Layout/Footer/Row/Choose").disabled).is_true()
		entries[0].available = false
		browser.configure(entries, "0")
		await _settle()
		assert_bool(browser.selection().is_empty()).is_true()
		assert_bool(browser.get_node("Layout/Footer/Row/Choose").disabled).is_true()
		assert_bool(browser.get_node("Layout/Footer/Row/Selection/Name").text == "Goblin 1").is_true()
		var empty: Array[Dictionary] = []
		browser.configure(empty, "")
		await _settle()
		assert_bool(browser.get_node("Layout/Results/Content/State").visible).is_true()
		assert_bool(browser.get_combined_minimum_size().x <= viewport.size.x).is_true()
		assert_bool(browser.get_combined_minimum_size().y <= viewport.size.y).is_true()
		viewport.free()

func _settle() -> void:
	for frame in range(8):
		await get_tree().process_frame

func _capture(viewport: SubViewport, name: String) -> void:
	if DisplayServer.get_name() == "headless":
		return
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--evidence-dir="):
			RenderingServer.force_draw()
			viewport.get_texture().get_image().save_png(argument.trim_prefix("--evidence-dir=").path_join(name + ".png"))

func test_resizing_an_open_browser_reflows_complete_cards() -> void:
	var viewport: SubViewport = auto_free(SubViewport.new())
	viewport.size = Vector2i(1920, 1080)
	add_child(viewport)
	var browser = load("res://rookframe/ui/components/content/fullscreen_miniature_browser.tscn").instantiate()
	viewport.add_child(browser)
	browser.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var entries: Array[Dictionary] = []
	for index in 15:
		entries.append({"id": str(index), "title": "Existing Miniature %d" % index, "package": "Existing Package"})
	browser.configure(entries, "0")
	await _settle()
	for size in [Vector2i(1024, 768), Vector2i(844, 390), Vector2i(1920, 1080)]:
		# A selection update can already be measuring when the parent resizes.
		browser.set_state("ready")
		await get_tree().process_frame
		viewport.size = size
		await _settle()
		await _settle()
		var rows: GridContainer = browser.get_node("Layout/Results/Content/GridArea/Rows")
		var visible := 0
		for row in rows.get_children():
			if row.visible:
				visible += 1
				assert_bool(row.get_global_rect().end.x <= size.x).is_true()
				assert_bool(row.get_node("Content").get_global_rect().end.x <= row.get_global_rect().end.x).is_true()
				assert_bool(row.get_node("Content/Stage").get_global_rect().end.y < row.get_node("Content/Copy").global_position.y).is_true()
		assert_int(visible).is_equal(3 if size.y < 560 else 6 if size.x <= 1150 else 8)
		assert_str(str(browser.selection().id)).is_equal("0")
	viewport.free()

func test_one_page_multiple_rows_remain_visible_after_layout() -> void:
	var viewport: SubViewport = auto_free(SubViewport.new())
	viewport.size = Vector2i(1920, 1080)
	add_child(viewport)
	var browser = load("res://rookframe/ui/components/content/fullscreen_miniature_browser.tscn").instantiate()
	viewport.add_child(browser)
	browser.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var entries: Array[Dictionary] = []
	for index in 6:
		entries.append({"id": str(index), "title": "Existing Miniature %d" % index, "package": "Existing Package"})
	browser.configure(entries, "0")
	await _settle()
	await _settle()
	for frame in 12:
		await get_tree().process_frame
		assert_bool(not browser.get_node("Layout/Results/Content/Pager").visible).is_true()
		assert_float(browser.get_node("Layout/Results/Content/GridArea/Rows").modulate.a).is_equal(1.0)
	viewport.free()
