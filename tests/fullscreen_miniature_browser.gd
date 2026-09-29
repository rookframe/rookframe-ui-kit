extends SceneTree

func _initialize() -> void:
	_check.call_deferred()

func _check() -> void:
	for profile in [[Vector2i(844, 390), 3], [Vector2i(1024, 768), 6], [Vector2i(1920, 1080), 8]]:
		var viewport := SubViewport.new()
		viewport.size = profile[0]
		viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		root.add_child(viewport)
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
		assert(previews.size() == 15)
		await _capture(viewport, "browser-" + str(viewport.size.x))
		var rows: GridContainer = browser.get_node("Layout/Results/Content/GridArea/Rows")
		var next: Button = browser.get_node("Layout/Results/Content/Pager/Next")
		var seen: Array[String] = []
		while true:
			var visible := 0
			for row in rows.get_children():
				if row.visible:
					visible += 1
					assert(not seen.has(row.accessibility_name))
					seen.append(row.accessibility_name)
					assert(row.get_global_rect().end.y <= next.get_global_rect().position.y)
					assert(row.get_global_rect().end.x <= viewport.size.x)
			assert(visible == mini(profile[1], 15 - seen.size() + visible))
			if next.disabled:
				break
			next.pressed.emit()
			await _settle()
		assert(seen.size() == 15)
		assert(browser.selection().id == "0")
		var search: LineEdit = browser.get_node("Layout/SearchArea/Content/Search")
		search.text = "Other Package"
		search.text_changed.emit(search.text)
		await _settle()
		assert(rows.get_children().filter(func(row): return row.visible).size() == 3)
		assert(browser.selection().id == "0")
		assert(not browser.get_node("Layout/Footer/Row/Choose").disabled)
		rows.get_child(14).pressed.emit()
		assert(browser.selection().id == "14")
		var actions := {"choose": 0, "cancel": 0, "close": 0}
		browser.choose_requested.connect(func(entry): assert(entry.id == "14"); actions.choose += 1)
		browser.cancel_requested.connect(func(): actions.cancel += 1)
		browser.close_requested.connect(func(): actions.close += 1)
		browser.get_node("Layout/Footer/Row/Choose").pressed.emit()
		browser.get_node("Layout/Footer/Row/Cancel").pressed.emit()
		browser.get_node("Layout/Header/Row/Close").pressed.emit()
		assert(actions == {"choose": 1, "cancel": 1, "close": 1})
		assert(browser.selection().id == "14")
		search.text = "no such miniature"
		search.text_changed.emit(search.text)
		await _settle()
		assert(browser.get_node("Layout/Results/Content/State").visible)
		assert(browser.selection().id == "14")
		browser.set_state("loading")
		assert(browser.get_node("Layout/Footer/Row/Choose").disabled)
		browser.set_state("error", "Could not load miniatures")
		assert(browser.get_node("Layout/Footer/Row/Choose").disabled)
		entries[0].available = false
		browser.configure(entries, "0")
		await _settle()
		assert(browser.selection().is_empty())
		assert(browser.get_node("Layout/Footer/Row/Choose").disabled)
		assert(browser.get_node("Layout/Footer/Row/Selection/Name").text == "Goblin 1")
		var empty: Array[Dictionary] = []
		browser.configure(empty, "")
		await _settle()
		assert(browser.get_node("Layout/Results/Content/State").visible)
		assert(browser.get_combined_minimum_size().x <= viewport.size.x)
		assert(browser.get_combined_minimum_size().y <= viewport.size.y)
		viewport.free()
	print("FULLSCREEN_MINIATURE_BROWSER 15 entries/all pages/search/selection/states/viewport fit PASS")
	quit()

func _settle() -> void:
	for frame in range(8):
		await process_frame

func _capture(viewport: SubViewport, name: String) -> void:
	if DisplayServer.get_name() == "headless":
		return
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--evidence-dir="):
			RenderingServer.force_draw()
			viewport.get_texture().get_image().save_png(argument.trim_prefix("--evidence-dir=").path_join(name + ".png"))
