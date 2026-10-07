extends GdUnitTestSuite

const SCENE = preload("res://rookframe/ui/components/content/silkbound_miniature_browser.tscn")
const LIST := "Inset/Layout/Body/Columns/List"
const FOOTER := "Inset/Layout/Footer/"

func test_search_and_choice_keep_the_draft_until_confirmation() -> void:
	var browser = auto_free(SCENE.instantiate())
	browser.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	browser.size = Vector2(1920,1080)
	add_child(browser)
	var entries: Array[Dictionary] = [{"id":"a", "title":"Knight", "package":"Core"}, {"id":"b", "title":"Bandit", "package":"Other"}]
	var chosen := []
	var cancelled := []
	browser.choose_requested.connect(func(entry): chosen.append(entry.id))
	browser.cancel_requested.connect(func(): cancelled.append(true))
	browser.configure(entries,"a")
	await _settle()
	var search: LineEdit = browser.get_node("Inset/Layout/Body/Search/Editor")
	search.text = "Other"
	search.text_changed.emit(search.text)
	await _settle()
	assert_str(browser.selection().id).is_equal("a")
	assert_bool(browser.get_node(LIST+"/Area/Rows").get_child(0).visible).is_false()
	browser.get_node(LIST+"/Area/Rows").get_child(1).pressed.emit()
	assert_array(chosen).is_empty()
	browser.get_node(FOOTER+"Choose").pressed.emit()
	assert_array(chosen).contains_exactly(["b"])
	browser.get_node(FOOTER+"Cancel").pressed.emit()
	assert_int(cancelled.size()).is_equal(1)
	browser.set_state("loading")
	assert_bool(browser.get_node(FOOTER+"Choose").disabled).is_true()
	browser.set_state("error","Retry")
	assert_bool(browser.get_node("Inset/Layout/Body/Retry").visible).is_true()
	entries[1].available = false
	browser.configure(entries,"b")
	await _settle()
	assert_bool(browser.selection().is_empty()).is_true()
	assert_bool(browser.get_node(FOOTER+"Choose").disabled).is_true()

func test_every_miniature_is_readable_at_each_canvas_and_after_resize() -> void:
	var viewport: SubViewport = auto_free(SubViewport.new())
	viewport.size = Vector2i(1920,1080)
	add_child(viewport)
	var browser = SCENE.instantiate()
	viewport.add_child(browser)
	browser.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var entries: Array[Dictionary] = []
	for index in 15: entries.append({"id":str(index), "title":"Miniature %d" % index, "package":"Core"})
	browser.configure(entries,"0")
	for dimensions in [Vector2i(1920,1080),Vector2i(1024,768),Vector2i(844,390),Vector2i(1920,1080)]:
		viewport.size = dimensions
		browser.get_node(LIST).restore_state({"page":0})
		await _settle()
		var seen := {}
		for page in 30:
			var bounds: Rect2 = browser.get_node(LIST+"/Area").get_global_rect()
			for row in browser.get_node(LIST+"/Area/Rows").get_children():
				if bounds.encloses(row.get_global_rect()): seen[row.get_index()] = true
			var next: Button = browser.get_node(LIST+"/Pager/Next")
			if next.disabled: break
			next.pressed.emit()
			await _settle()
		assert_int(seen.size()).is_equal(15)
		assert_str(browser.selection().id).is_equal("0")
		assert_float(browser.get_node(FOOTER+"Choose").get_global_rect().end.y).is_less_equal(dimensions.y)
		assert_float(browser.get_combined_minimum_size().x).is_less_equal(dimensions.x)

func _settle() -> void:
	for frame in 12: await get_tree().process_frame
