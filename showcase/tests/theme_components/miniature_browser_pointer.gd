extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	# Cross a layout frame while the native Button is held; signal-only tests
	# cannot detect canceled mouse presses in the paginated browser.
	root.size = Vector2i(1024, 768)
	var browser = load("res://rookframe/ui/silkbound-ledger/components/content/miniature_browser.tscn").instantiate()
	browser.paginated = true
	root.add_child(browser)
	browser.size = Vector2(1000, 700)
	var entries: Array[Dictionary] = [{"id": "goblin", "title": "Goblin", "package": "Pieces", "available": true}, {"id": "bandit", "title": "Bandit", "package": "Pieces", "available": true}]
	browser.configure(entries)
	for i in 12: await process_frame
	var row: Button = browser.get_node("Results/Rows").get_child(1)
	var point := row.get_global_rect().get_center()
	var motion := InputEventMouseMotion.new()
	motion.position = point
	root.push_input(motion, true)
	for pressed in [true, false]:
		var event := InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = pressed
		event.position = point
		root.push_input(event, true)
		await process_frame
	var selected: Dictionary = browser.selection()
	if selected.get("id") != "bandit":
		printerr("FAIL: pointer click leaves miniature selection empty: ", selected)
		quit(1)
	else:
		print("PASS: pointer click selects Bandit")
		quit(0)
