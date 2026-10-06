extends GdUnitTestSuite

func test_editing_and_resizing_preserve_every_character(width: int, height: int, _test_parameters := [[606,581],[606,369],[740,180]]) -> void:
	var note = auto_free(load("res://rookframe/ui/components/forms/paginated_text_area.tscn").instantiate())
	note.theme = load("res://rookframe/ui/theme/silkbound_theme.tres")
	add_child(note)
	note.size = Vector2(width, height)
	note.compact = height < 200
	var words := "The forest remembers everything. A journal entry keeps its words across every page.\n".repeat(80)
	note.value = words
	await _settle()
	assert_int(note._pages.size()).is_greater(1)
	assert_str("".join(note._pages)).is_equal(words)
	for page in note._pages.size():
		note._page = page
		note._show_page()
		var editor: TextEdit = note.get_node("Editor")
		var available := editor.size.y - editor.get_theme_stylebox("normal").get_minimum_size().y
		assert_bool(editor.get_total_visible_line_count() * editor.get_line_height() <= available + 1).is_true()
	note._page = 0
	note._show_page()
	var first: String = note._pages[0]
	note._turn(1)
	var editor: TextEdit = note.get_node("Editor")
	editor.set_caret_line(0)
	editor.set_caret_column(0)
	editor.insert_text_at_caret("Written here. ")
	await _settle()
	assert_str(note.value).is_equal(first + "Written here. " + words.substr(first.length()))
	note.size = Vector2(width / 2.0, height)
	await _settle()
	assert_str("".join(note._pages)).is_equal(note.value)
	note.value = ""
	await _settle()
	assert_bool(note.get_node("Pager/Previous").disabled).is_true()
	assert_bool(note.get_node("Pager/Next").disabled).is_true()
	assert_str(note.get_node("Pager/Range").text).is_equal("1 / 1")

func _settle() -> void:
	for frame in 6:
		await get_tree().process_frame
