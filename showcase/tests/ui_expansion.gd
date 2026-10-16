extends SceneTree
## Native rendering and interaction matrix for the production expansion specimen.
const EXAMPLE = preload("res://examples/ui-expansion/specimen.tscn")
var failures: Array[String] = []
var captures := 0

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	var capture_dir := ""
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--capture-dir="): capture_dir = arg.trim_prefix("--capture-dir=")
	if not capture_dir.is_empty(): DirAccess.make_dir_recursive_absolute(capture_dir)
	root.gui_embed_subwindows = true
	var example := EXAMPLE.instantiate()
	root.add_child(example)
	await settle(8)
	for canvas in [Vector2i(1920, 1080), Vector2i(1024, 768), Vector2i(844, 390)]:
		root.size = canvas
		for theme in 3:
			example.theme_index = theme
			example.apply_presentation()
			for page in example.tabs.get_tab_count():
				example.tabs.current_tab = page
				await settle(8)
				if example.size.x > canvas.x + 1: failures.append("Specimen exceeds canvas width")
				await capture(capture_dir, "%dx%d-theme%d-page%d" % [canvas.x, canvas.y, theme, page])
		# Language/font-scale cases use retained input and typography contexts.
		for language in 8:
			example.language_index = language
			for scale in [1.0, 1.5]:
				example.text_scale = scale
				example.long_content = true
				example.reduced_motion = true
				example.apply_presentation()
				example.tabs.current_tab = example.tabs.get_tab_count() - 1
				await settle(8)
				await capture(capture_dir, "%dx%d-lang%d-scale%s" % [canvas.x, canvas.y, language, str(scale)])
		example.text_scale = 1.0
		example.language_index = 0
		example.long_content = false
		example.reduced_motion = false
	print("UI_EXPANSION: ", captures, " captures; ", failures.size(), " failures; Godot ", Engine.get_version_info().string, "; ", OS.get_name(), "; renderer=", RenderingServer.get_current_rendering_method(), "; GPU=", RenderingServer.get_video_adapter_name())
	example.free()
	for failure in failures: push_error(failure)
	quit(0 if failures.is_empty() else 1)

func settle(frames: int) -> void:
	for i in frames: await process_frame

func capture(directory: String, name: String) -> void:
	if directory.is_empty() or DisplayServer.get_name() == "headless": return
	await RenderingServer.frame_post_draw
	var result := root.get_texture().get_image().save_png(directory.path_join(name + ".png"))
	if result != OK: failures.append("Cannot save " + name)
	else: captures += 1
