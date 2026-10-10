extends GdUnitTestSuite


func test_rookframe_theme_keeps_deep_load_bounded() -> void:
	_check_deep_load("res://rookframe/ui/theme/rookframe_theme.tres")


func test_fullscreen_theme_keeps_deep_load_bounded() -> void:
	_check_deep_load("res://rookframe/ui/theme/fullscreen_task_theme.tres")


func test_silkbound_theme_keeps_deep_load_bounded() -> void:
	_check_deep_load("res://rookframe/ui/theme/silkbound_theme.tres")


func _check_deep_load(path: String) -> void:
	# Package loading deliberately ignores the global cache, including dependencies.
	# Repeated font references must share within this Theme's own resource graph.
	var before := OS.get_static_memory_usage()
	var isolated := ResourceLoader.load(path, "Theme", ResourceLoader.CACHE_MODE_IGNORE_DEEP) as Theme
	var bytes := OS.get_static_memory_usage() - before
	print("Theme deep load: %s, %.1f MiB" % [path, bytes / 1048576.0])
	assert_object(isolated).is_not_null()
	assert_int(bytes).is_less(256 * 1024 * 1024)
	var ordinary := load(path) as Theme
	for type in ordinary.get_type_list():
		for name in ordinary.get_font_list(type):
			var expected := ordinary.get_font(name, type)
			var actual := isolated.get_font(name, type)
			assert_object(actual).is_not_same(expected)
			for sample in ["Garamond 0123456789", "日本語", "한국어", "简体中文", "繁體中文"]:
				assert_vector(actual.get_string_size(sample, HORIZONTAL_ALIGNMENT_LEFT, -1, 24)).is_equal(expected.get_string_size(sample, HORIZONTAL_ALIGNMENT_LEFT, -1, 24))
			assert_float(actual.get_height(24)).is_equal(expected.get_height(24))
