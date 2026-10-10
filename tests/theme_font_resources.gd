extends GdUnitTestSuite


func test_rookframe_theme_keeps_deep_load_bounded() -> void:
	_check_deep_load("res://rookframe/ui/theme/rookframe_theme.tres")


func test_fullscreen_theme_keeps_deep_load_bounded() -> void:
	_check_deep_load("res://rookframe/ui/theme/fullscreen_task_theme.tres")


func test_silkbound_theme_keeps_deep_load_bounded() -> void:
	_check_deep_load("res://rookframe/ui/theme/silkbound_theme.tres")


func _check_deep_load(path: String) -> void:
	# Deliberately bypass the cache to measure the complete cold Theme cost.
	# This must stay bounded even before any native dependency reuse.
	var before := OS.get_static_memory_usage()
	var isolated := ResourceLoader.load(path, "Theme", ResourceLoader.CACHE_MODE_IGNORE_DEEP) as Theme
	var bytes := OS.get_static_memory_usage() - before
	print("Theme deep load: %s, %.1f MiB" % [path, bytes / 1048576.0])
	assert_object(isolated).is_not_null()
	assert_int(bytes).is_less(64 * 1024 * 1024)
	var ordinary := load(path) as Theme
	for type in ordinary.get_type_list():
		for name in ordinary.get_font_list(type):
			var expected := ordinary.get_font(name, type)
			var actual := isolated.get_font(name, type)
			assert_object(actual).is_not_same(expected)
			for sample in ["Garamond 0123456789", "日本語", "한국어", "简体中文", "繁體中文"]:
				assert_vector(actual.get_string_size(sample, HORIZONTAL_ALIGNMENT_LEFT, -1, 24)).is_equal(expected.get_string_size(sample, HORIZONTAL_ALIGNMENT_LEFT, -1, 24))
			assert_float(actual.get_height(24)).is_equal(expected.get_height(24))


func test_explicit_regional_fonts_keep_native_text_coverage() -> void:
	for locale in ["ja", "ko", "zh_CN", "zh_TW"]:
		var font := load("res://rookframe/ui/theme/locales/%s_regular.tres" % locale) as FontVariation
		assert_int(font.fallbacks.size()).is_equal(1)
		assert_bool(font.has_char(0x4E00) if locale != "ko" else font.has_char(0xD55C)).is_true()
		assert_float(font.get_string_size("Mörk Borg / 日本語 / 한국어 / 中文", HORIZONTAL_ALIGNMENT_LEFT, -1, 24).x).is_greater(0.0)
