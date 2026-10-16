extends SceneTree
## Focused contracts and captures for the complete host recipe compositions.
const EXAMPLE = preload("res://examples/ui-expansion/specimen.tscn")
var failures: Array[String] = []
var assertions := 0
var captures := 0
var directory := "/tmp/rookframe-ui-expansion/recipes"
func _initialize() -> void:
	_run.call_deferred()
func check(value: bool, message: String) -> void:
	assertions += 1
	if not value: failures.append(message)
func _run() -> void:
	DirAccess.make_dir_recursive_absolute(directory)
	root.gui_embed_subwindows = true
	var example = EXAMPLE.instantiate()
	root.add_child(example)
	for canvas in [Vector2i(1920, 1080), Vector2i(1024, 768), Vector2i(844, 390)]:
		root.size = canvas
		for theme in 3:
			example.theme_index = theme
			example.apply_presentation()
			var prefix := "%dx%d-theme%d-" % [canvas.x, canvas.y, theme]
			for page in [1, 2, 3, 4, 5]:
				example.tabs.current_tab = page
				await settle()
				check(example.size.x <= canvas.x + 1, "Recipe remains within canvas width")
				await capture(prefix + "page%d" % page)
			for context in 2:
				example.tabs.current_tab = 3 + context
				await settle()
				var popup = example.selection_popovers[context]
				check(popup.open_for(example.collection_menus[context]), "Selection popup opens in collection context")
				await settle()
				check(popup.position.y + popup.size.y <= canvas.y, "Selection is bounded with native scrolling")
				await capture(prefix + "selection%d" % context)
				popup.close()
				example.simulate_retrieval(context)
				await settle()
				var state: Dictionary = example.retrievals[context]
				check(state.accepted == state.generation and state.ignored > 0, "COL-14 Latest generation wins")
			example.tabs.current_tab = 4
			example.asset_previews[1].open_for(example.collection_menus[1])
			await settle()
			await capture(prefix + "asset-preview")
			example.asset_previews[1].close()
	# Both host result policies share the public context protocol.
	for context in 2:
		example.tabs.current_tab = 3 + context
		await settle()
		var transfer = example.contexts[context]
		check(transfer.begin_transfer("bag"), "Source is available in its host context")
		var request: int = transfer.request_placement("equipment")
		check(request > 0, "Host receives one issued request")
		if context == 0:
			check(transfer.get_state() == &"idle", "Inventory host resolves synchronously")
		else:
			check(transfer.get_state() == &"pending", "Asset host retains delayed request")
			await create_timer(0.3).timeout
			check(transfer.get_state() == &"idle", "Asset host resolves matching delayed result")
	example.free()
	print("UI_EXPANSION_RECIPES: ", assertions, " assertions; ", failures.size(), " failures; ", captures, " captures")
	for failure in failures: push_error(failure)
	quit(0 if failures.is_empty() else 1)
func settle() -> void:
	for i in 8: await process_frame
func capture(name: String) -> void:
	await RenderingServer.frame_post_draw
	if root.get_texture().get_image().save_png(directory.path_join(name + ".png")) == OK: captures += 1
	else: failures.append("Failed capture " + name)
