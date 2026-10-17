extends SceneTree
## Exercise the catalogue's host wiring through native keyboard activation.
const Catalogue = preload("res://examples/components/catalogue.tscn")
var failures: Array[String] = []
var catalogue: Control
var capture_dir := ""

func _initialize() -> void:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--capture-dir="):
			capture_dir = argument.trim_prefix("--capture-dir=")
	if not capture_dir.is_empty():
		DirAccess.make_dir_recursive_absolute(capture_dir)
	_run.call_deferred()

func _run() -> void:
	root.gui_embed_subwindows = true
	root.size = Vector2i(1024, 768)
	catalogue = Catalogue.instantiate()
	root.add_child(catalogue)
	await settle()
	catalogue.show_page("field")
	await settle()
	var field = resource_node("res://rookframe/ui/components/forms/field.tscn")
	await activate(button("Show error"))
	check(not field.error_text.is_empty(), "Field's Show error action updates validation")
	await activate(button("Focus input"))
	check(root.gui_get_focus_owner() is LineEdit, "Field's focus action reaches the native editor")
	await capture("field-error-focus")
	await activate(button("Clear error"))
	check(field.error_text.is_empty(), "Field's Clear error action clears validation")

	catalogue.show_page("multi_select_picker")
	await settle()
	var pickers: Array = catalogue.current_page.find_children("*", "VBoxContainer", true, false).filter(func(node): return node.has_method("get_selected_ids"))
	await activate(button("Load / empty collection"))
	check(pickers.size() == 2, "Both multi-select states are present")
	check(pickers[1].set_selected_ids(PackedStringArray(["archive"])), "Loading the empty example supplies selectable records")
	await activate(button("Load / empty collection"))
	check(pickers[1].get_selected_ids().is_empty(), "Emptying the example reconciles its selected records")

	catalogue.show_page("tabs")
	await settle()
	var tabs: TabContainer = catalogue.current_page.find_children("*", "TabContainer", true, false)[0]
	var editor: LineEdit = tabs.get_child(0).find_children("*", "LineEdit", true, false)[0]
	editor.text = "Retained after navigation"
	tabs.current_tab = 1
	tabs.current_tab = 0
	check(editor.text == "Retained after navigation", "Tab examples retain the same editor")
	check(tabs.is_tab_disabled(2), "Unavailable tab is disabled")
	await capture("tabs-retained")

	catalogue.show_page("popover")
	await settle()
	var popup = resource_node("res://rookframe/ui/components/overlays/popover.tscn")
	var anchor := button("Edit expedition name")
	await activate(anchor)
	check(popup.is_open(), "Popover trigger opens the production popup")
	check(popup.gui_get_focus_owner() is LineEdit, "Popover starts in its native editor")
	await capture("popover-open")
	popup.close(&"cancel")
	await settle()
	check(not popup.is_open() and anchor.has_focus(), "Popover cancellation restores its trigger focus")
	await activate(anchor)
	catalogue.show_page("field")
	await settle()
	check(not is_instance_valid(popup), "Navigation disposes page-owned popups")

	catalogue.show_page("spinner")
	await settle()
	catalogue.set_reduced_motion(false)
	var fixed: Node = catalogue.current_page.find_children("*", "", true, false).filter(func(node): return node.get_meta("fixed_reduced_motion", false))[0]
	check(fixed.reduced_motion, "The explicitly static spinner remains static with global motion enabled")
	catalogue.set_reduced_motion(true)
	check(fixed.reduced_motion, "Global reduced motion preserves the static comparison")
	catalogue.set_reduced_motion(false)

	for id in ["card_switch", "menu_button_destructive"]:
		catalogue.show_page(id)
		await settle()
		var choice: OptionButton = catalogue.current_page.find_children("*", "OptionButton", true, false).filter(func(node): return node.accessibility_name == "Auxiliary shell appearance")[0]
		var controls: Array = catalogue.current_page.find_children("*", "Control", true, false).filter(func(node): return node.has_meta("showcase_shell_recipe"))
		var retained: Control = controls[0]
		choice.select(1)
		choice.item_selected.emit(1)
		await settle()
		check(is_instance_valid(retained), "Changing appearance retains the specimen controls")
		check(retained.theme.resource_path.ends_with("CyberpunkTheme.tres"), "Appearance selector applies the Cyberpunk production theme")
		await capture(id + "-cyberpunk")

	root.size = Vector2i(844, 390)
	await settle()
	catalogue._toggle_navigation()
	catalogue.search.text = "Field"
	catalogue.search.text_changed.emit("Field")
	catalogue.search.text_submitted.emit("Field")
	await settle()
	check(catalogue.current_id == "field", "Compact search opens the selected component")
	check(catalogue.main.visible and not catalogue.sidebar.visible, "Compact selection returns to the component")
	check(catalogue.content_scroll.has_focus(), "Compact navigation returns keyboard focus to the content")
	await capture("compact-keyboard-navigation")
	catalogue.free()
	await settle()
	print("COMPONENT_CATALOGUE_INTERACTIONS: %d failures" % failures.size())
	quit(0 if failures.is_empty() else 1)

func resource_node(path: String) -> Node:
	return catalogue.current_page.find_children("*", "", true, false).filter(func(node): return node.scene_file_path == path)[0]

func button(copy: String) -> Button:
	for node in catalogue.current_page.find_children("*", "Button", true, false):
		if node.text == copy:
			return node
	assert(false, "Missing example action: " + copy)
	return null

func activate(control: Button) -> void:
	control.grab_focus()
	await settle()
	for pressed in [true, false]:
		var event := InputEventAction.new()
		event.action = &"ui_accept"
		event.pressed = pressed
		Input.parse_input_event(event)
		await process_frame
	await settle()

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
