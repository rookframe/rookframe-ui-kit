extends SceneTree

func _initialize() -> void:
	call_deferred("_check")

func _check() -> void:
	var browser = load("res://rookframe/ui/components/content/miniature_browser.tscn").instantiate()
	root.add_child(browser)
	browser.size = Vector2(351, 229)
	var entries: Array[Dictionary] = [{"id": "one/goblin", "title": "Гоблин", "package": "Первый пакет", "available": true}, {"id": "two/goblin", "title": "Гоблин", "package": "Второй пакет", "available": true}, {"id": "gone", "title": "Недоступная миниатюра", "package": "Пакет", "available": false}]
	browser.configure(entries, "two/goblin", {"search": "Поиск миниатюр", "no_match": "Миниатюры не найдены."})
	assert(browser.selection().id == "two/goblin")
	assert(browser.get_node("Search").placeholder_text == "Поиск миниатюр")
	browser.get_node("Search").text_changed.emit("первый")
	assert(browser.get_node("Results/Rows").get_child(0).visible)
	assert(not browser.get_node("Results/Rows").get_child(1).visible)
	browser.get_node("Results/Rows").get_child(0).pressed.emit()
	assert(browser.selection().id == "one/goblin")
	browser.get_node("Search").text_changed.emit("missing")
	assert(browser.get_node("Status").text == "Миниатюры не найдены.")
	browser.set_state("error", "Не удалось загрузить")
	assert(browser.get_node("Retry").visible)
	browser.configure(entries, "gone")
	assert(browser.selection().is_empty())
	await process_frame
	assert(browser.get_combined_minimum_size().x <= 351)
	browser.queue_free()
	print("Miniature browser selection, source identity, localization and states passed")
	quit()
