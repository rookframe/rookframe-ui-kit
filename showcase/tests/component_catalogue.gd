extends SceneTree
## Navigation and layout integration checks against every dedicated component view.
const Catalogue = preload("res://examples/components/catalogue.tscn")
var failures: Array[String] = []
var cases := 0
var capture_dir := ""
var only_category := ""
var only_page := ""

func _initialize() -> void:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--capture-dir="):
			capture_dir = argument.trim_prefix("--capture-dir=")
		if argument.begins_with("--category="):
			only_category = argument.trim_prefix("--category=")
		if argument.begins_with("--only="):
			only_page = argument.trim_prefix("--only=")
	if not capture_dir.is_empty():
		DirAccess.make_dir_recursive_absolute(capture_dir)
	_run.call_deferred()

func _run() -> void:
	root.gui_embed_subwindows = true
	var catalogue := Catalogue.instantiate()
	root.add_child(catalogue)
	await settle()
	check(not catalogue.entries.is_empty(), "The component catalogue must have entries")
	check(catalogue.current_id.is_empty(), "Launch opens the grouped overview")
	check(not catalogue.show_page("missing-component"), "Unknown component IDs must not replace the current view")
	await capture("launch")
	# The layout matrix uses exact native pixels, independent of desktop DPI.
	root.content_scale_factor = 1.0
	for canvas in [Vector2i(1920, 1080), Vector2i(1024, 768), Vector2i(844, 390)]:
		root.size = canvas
		catalogue.show_page("")
		await settle()
		await capture("%dx%d-overview" % [canvas.x, canvas.y])
		check(catalogue.size.x <= canvas.x + 1, "Catalogue exceeds canvas width")
		check(catalogue.main.visible, "Content remains visible after resize")
		if canvas.x < 1000:
			catalogue._toggle_navigation()
			check(catalogue.sidebar.visible and not catalogue.main.visible, "Compact navigation is independently reachable")
			await settle()
			await capture("%dx%d-navigation" % [canvas.x, canvas.y])
			catalogue._toggle_navigation()
		for entry in catalogue.entries:
			if not only_page.is_empty() and not entry.id in only_page.split(","):
				continue
			if not only_category.is_empty() and entry.category != only_category:
				continue
			check(catalogue.show_page(entry.id), "Route opens: " + entry.id)
			await settle()
			var page: VBoxContainer = catalogue.current_page
			check(page.examples.size() >= 2, "At least two state or variant examples: " + entry.id)
			check(page.get_combined_minimum_size().x <= page.size.x + 1, "Minimum width fits: " + entry.id)
			check(page.get_global_rect().end.x <= canvas.x + 1, "Page fits horizontally: %s at %s" % [entry.id, canvas])
			check(catalogue.nav_buttons[entry.id].button_pressed, "Navigation identifies active component: " + entry.id)
			check(catalogue.content_scroll.scroll_vertical == 0, "New page starts at its heading: " + entry.id)
			catalogue.set_reduced_motion(true)
			check(page.reduced_motion, "Reduced motion reaches component page")
			await capture("%dx%d-%s" % [canvas.x, canvas.y, entry.id])
			if not capture_dir.is_empty():
				catalogue.content_scroll.scroll_vertical = int(catalogue.content_scroll.get_v_scroll_bar().max_value)
				await settle()
				await capture("%dx%d-%s-last" % [canvas.x, canvas.y, entry.id])
			catalogue.set_reduced_motion(false)
			cases += 1
		catalogue.show_page("")
		await settle()
	var first: Dictionary = catalogue.entries[0]
	catalogue.filter_navigation(first.title)
	check(catalogue.nav_buttons[first.id].visible, "Search finds the matching component")
	catalogue.filter_navigation("no-such-component-9382")
	for button in catalogue.nav_buttons.values():
		check(not button.visible, "Unmatched search hides component links")
	check(catalogue._empty.visible, "Unmatched search has an empty state")
	catalogue.filter_navigation("")
	catalogue.show_page(first.id)
	catalogue._adjacent(1)
	check(catalogue.current_id == catalogue.entries[1].id, "Next navigates in category order")
	catalogue._adjacent(-1)
	check(catalogue.current_id == first.id, "Previous navigates in category order")
	catalogue.free()
	await settle()
	print("COMPONENT_CATALOGUE: %d pages at native sizes; %d failures" % [cases, failures.size()])
	quit(0 if failures.is_empty() else 1)

func check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
		push_error(message)

func settle() -> void:
	for frame in 6:
		await process_frame

func capture(name: String) -> void:
	if capture_dir.is_empty() or DisplayServer.get_name() == "headless":
		return
	await RenderingServer.frame_post_draw
	check(root.get_texture().get_image().save_png(capture_dir.path_join(name + ".png")) == OK, "Capture " + name)
