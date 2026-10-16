extends SceneTree
## Focused follow-up captures for live form, overlay, feedback and transfer states.
const EXAMPLE = preload("res://examples/ui-expansion/specimen.tscn")
var directory := "/tmp/rookframe-ui-expansion/states"
func _initialize() -> void:
	_run.call_deferred()
func _run() -> void:
	DirAccess.make_dir_recursive_absolute(directory)
	root.gui_embed_subwindows = true
	var example := EXAMPLE.instantiate()
	root.add_child(example)
	for canvas in [Vector2i(1920, 1080), Vector2i(1024, 768), Vector2i(844, 390)]:
		root.size = canvas
		for theme in 3:
			example.theme_index = theme
			example.apply_presentation()
			var prefix := "%dx%d-theme%d-" % [canvas.x, canvas.y, theme]
			example.tabs.current_tab = 1
			example.fields[0].set_error("Capacity is unavailable")
			example.fields[0].focus_input()
			await settle()
			await capture(prefix + "field")
			var inspect = example.inspections[0]
			var source: Control = inspect.get_parent().get_child(inspect.get_index() - 1)
			example.tabs.get_child(1).ensure_control_visible(source)
			await settle()
			inspect.open_inspection()
			await settle()
			await capture(prefix + "inspection")
			inspect.close()
			example.tabs.current_tab = 3
			await settle()
			await capture(prefix + "collection")
			example.contexts[0].begin_transfer("bag")
			await settle()
			await capture(prefix + "carrying")
			example.contexts[0].cancel_transfer()
			example.tabs.current_tab = 5
			var stack = example.toasts[0]
			stack.clear()
			for i in 3:
				stack.push({"id": str(i), "title": "Item saved", "description": "The host owns the Undo action.", "action_id": "undo", "action_label": "Undo"})
			await settle()
			await capture(prefix + "toast")
			example.fields[0].set_error("")
	example.free()
	print("UI_EXPANSION_STATES: 45 native captures")
	quit()
func settle() -> void:
	for i in 8: await process_frame
func capture(name: String) -> void:
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(directory.path_join(name + ".png"))
