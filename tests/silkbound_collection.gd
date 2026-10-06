extends GdUnitTestSuite

func test_bounded_records_keep_details_and_actions_independent() -> void:
	for canvas in [Vector2i(1920, 1080), Vector2i(1024, 768), Vector2i(844, 390)]:
		var viewport: SubViewport = auto_free(SubViewport.new())
		viewport.size = canvas
		add_child(viewport)
		var collection = load("res://rookframe/ui/components/data/silkbound_collection.tscn").instantiate()
		collection.theme = load("res://rookframe/ui/theme/silkbound_theme.tres")
		collection.size = Vector2(500, 240)
		viewport.add_child(collection)
		var entries: Array[Dictionary] = []
		for index in 12:
			entries.append({"id": str(index), "title": "Equipment %d" % index, "subtitle": "An ordinary belonging", "action": "Equip", "action_text": "Equip"})
		var calls := {"details": "", "action": ""}
		collection.selected.connect(func(id): calls.details = id)
		collection.action_requested.connect(func(id): calls.action = id)
		collection.configure(entries, "", "Inventory", "12 items")
		await _settle()
		var rows: GridContainer = collection.get_node("Content/Area/Rows")
		var next: Button = collection.get_node("Content/Pager/Next")
		var visited: Array[String] = []
		while true:
			for row in rows.get_children():
				if row.visible:
					var details: Button = row.get_node("Details")
					assert_bool(row.get_global_rect().end.y <= next.global_position.y).is_true()
					details.pressed.emit()
					assert_bool(not visited.has(calls.details)).is_true()
					visited.append(calls.details)
			if next.disabled:
				break
			next.pressed.emit()
			await _settle()
		assert_int(visited.size()).is_equal(12)
		assert_str(calls.action).is_empty()
		assert_bool(collection.focus_entry("7")).is_true()
		await _settle()
		assert_bool(rows.get_child(7).get_node("Details").has_focus()).is_true()
		rows.get_child(7).get_node("Action").pressed.emit()
		assert_str(calls.action).is_equal("7")
		assert_str(calls.details).is_equal("11")
		var state: Dictionary = collection.capture_state()
		entries[7].title = "Updated equipment"
		collection.configure(entries, "", "Inventory", "12 items")
		collection.restore_state(state)
		await _settle()
		assert_bool(collection.capture_state() == state).is_true()
		assert_bool(rows.get_child(7).get_node("Details").has_focus()).is_true()
		var empty: Array[Dictionary] = []
		collection.configure(empty, "")
		await _settle()
		assert_bool(collection.get_node("Content/Area/Empty").visible).is_true()
		assert_bool(next.disabled).is_true()
		viewport.free()

func _settle() -> void:
	for frame in 12:
		await get_tree().process_frame
