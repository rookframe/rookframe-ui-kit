extends SceneTree
## Shared Button native layout and inherited appearance in real consumers.
const Catalogue = preload("res://examples/components/catalogue.tscn")
const THEMES := {
	"native": "",
	"ledger": "res://rookframe/ui/themes/silkbound-ledger/theme.tres",
	"fantasy": "res://rookframe/ui/themes/fantasy/theme.tres",
	"cyberpunk": "res://rookframe/ui/themes/cyberpunk/theme.tres",
}
var failures: Array[String] = []
var capture_dir := ""
var preview := ""

func _initialize() -> void:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--capture-dir="):
			capture_dir = argument.trim_prefix("--capture-dir=")
		if argument.begins_with("--preview="):
			preview = argument.trim_prefix("--preview=")
	if not capture_dir.is_empty(): DirAccess.make_dir_recursive_absolute(capture_dir)
	_run.call_deferred()

func _run() -> void:
	root.gui_embed_subwindows = true
	var catalogue = Catalogue.instantiate()
	root.add_child(catalogue)
	await settle()
	if not preview.is_empty():
		if not THEMES.has(preview):
			push_error("Unknown preview theme: %s. Choose native, ledger, fantasy or cyberpunk." % preview)
			quit(2)
			return
		catalogue.select_theme("silkbound-ledger" if preview == "ledger" else preview)
		catalogue.show_page("button")
		await settle()
		if not capture_dir.is_empty(): await capture("preview-" + preview)
		return
	root.content_scale_factor = 1.0
	catalogue.show_page("button")
	var page = catalogue.current_page
	var actions: Array = page.find_children("*", "Button", true, false).filter(func(node): return node.scene_file_path == "res://rookframe/ui/components/actions/button.tscn")
	check(actions.size() == 34, "One production Button supplies the complete variant matrix")
	for theme_name in THEMES:
		var skin: Theme = ThemeDB.get_default_theme() if theme_name == "native" else load(THEMES[theme_name])
		catalogue.select_theme("silkbound-ledger" if theme_name == "ledger" else theme_name)
		for canvas in [Vector2i(1920, 1080), Vector2i(1024, 768), Vector2i(844, 390)]:
			root.size = canvas
			await settle()
			check(page.get_combined_minimum_size().x <= page.size.x + 1, "%s fits %s" % [theme_name, canvas])
			for control in actions:
				check(control.get_combined_minimum_size().y >= (44 if control.compact else 52), "Every button retains its density target")
				check(control.get_global_rect().end.x <= canvas.x + 1, "%s button fits canvas: %s" % [theme_name, control.text])
				if not control.icon == null:
					check(control.text != "" or not control.accessibility_name.is_empty(), "Icon-only actions have accessible names")
			if theme_name == "native":
				for dark in [false, true]:
					catalogue.theme = catalogue.Chrome.create(dark)
					catalogue.set_reduced_motion(dark)
					await settle()
					for control in actions:
						check(control.get_theme_stylebox("normal") == skin.get_stylebox("normal", "Button"), "Unmapped variants keep the native preview surface under either chrome")
					await capture_sections(catalogue, "%s-%s-%dx%d" % [theme_name, "dark" if dark else "light", canvas.x, canvas.y], 5)
			else:
				await capture_sections(catalogue, "%s-%dx%d" % [theme_name, canvas.x, canvas.y], 3)
		# Each role is supplied by the optional consumer, including compact fallback.
		if theme_name != "native":
			for control in actions:
				check(skin.get_type_variation_base(control.theme_type_variation) != &"", "Consumer maps " + String(control.theme_type_variation))
				if theme_name == "ledger":
					check(control.get_theme_color("icon_normal_color") == control.get_theme_color("font_color"), "Selected foreground applies to icons and labels")
	catalogue.free()
	for failure in failures: push_error(failure)
	print("BUTTON_SHOWCASE: 4 themes at 3 sizes; %d failures" % failures.size())
	quit(0 if failures.is_empty() else 1)

func capture_sections(catalogue, prefix: String, count: int) -> void:
	if capture_dir.is_empty(): return
	for index in count:
		var block: Control = catalogue.current_page.section_blocks[index]
		catalogue.content_scroll.scroll_vertical += roundi(block.global_position.y - catalogue.content_scroll.global_position.y)
		await settle()
		await capture(prefix + "-" + str(index))
		if index < 2:
			var buttons := block.find_children("*", "Button", true, false)
			var control: Button = buttons[2]
			control.grab_focus()
			await settle()
			check(control.has_focus(), "Icon-only actions accept native focus")
			await capture(prefix + "-focused-" + str(index))
			var event := InputEventAction.new()
			event.action = &"ui_accept"
			event.pressed = true
			root.push_input(event)
			await settle()
			await capture(prefix + "-pressed-" + str(index))
			event.pressed = false
			root.push_input(event)
			control.release_focus()

func check(condition: bool, message: String) -> void:
	if not condition: failures.append(message)

func settle() -> void:
	for frame in 6: await process_frame

func capture(name: String) -> void:
	if DisplayServer.get_name() == "headless": return
	await RenderingServer.frame_post_draw
	check(root.get_texture().get_image().save_png(capture_dir.path_join(name + ".png")) == OK, "Capture " + name)
