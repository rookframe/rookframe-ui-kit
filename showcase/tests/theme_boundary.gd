extends SceneTree
const EXAMPLE = preload("res://examples/theme-boundary/theme_boundary.tscn")
var failures: Array[String] = []

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	var capture_dir := ""
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--capture-dir="): capture_dir = arg.trim_prefix("--capture-dir=")
	if not capture_dir.is_empty(): DirAccess.make_dir_recursive_absolute(capture_dir)
	for canvas in [Vector2i(1920, 1080), Vector2i(1024, 768), Vector2i(844, 390)]:
		root.size = canvas
		var example := EXAMPLE.instantiate()
		root.add_child(example)
		for i in 12: await process_frame
		var columns := example.get_child(0).get_child(0)
		var base := columns.get_child(0)
		var skin := columns.get_child(1)
		if base.get_child(1).theme != null: failures.append("Base field assigns a theme")
		if skin.theme != load("res://rookframe/ui/themes/silkbound-ledger/theme.tres"):
			failures.append("Skin did not select the canonical Theme")
		for index in range(1, base.get_child_count()):
			if base.get_child(index).scene_file_path != skin.get_child(index).scene_file_path:
				failures.append("Appearance must use the same component scenes")
		if base.get_child(4)._rows.size() != 8: failures.append("Base choice data was lost")
		if base.get_child(4)._rows[1].button_pressed != true: failures.append("Base choice selection was lost")
		# Host fonts must reach nested public slots even with Silkbound installed.
		var host_theme := Theme.new()
		host_theme.default_font_size = 23
		base.theme = host_theme
		for i in 4: await process_frame
		if base.get_child(1).get_node("Label").get_theme_font_size("font_size") != 23:
			failures.append("Base label overrides host font size")
		if base.get_child(2).get_node("Perimeter/Row/Editor").get_theme_font_size("font_size") != 23:
			failures.append("Base search overrides host font size")
		base.theme = null
		if not capture_dir.is_empty() and DisplayServer.get_name() != "headless":
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png(capture_dir.path_join("boundary-%dx%d.png" % [canvas.x, canvas.y]))
		root.remove_child(example)
		example.free()
	for failure in failures: push_error(failure)
	print("THEME_BOUNDARY: 3 sizes, ", failures.size(), " failures")
	quit(0 if failures.is_empty() else 1)
