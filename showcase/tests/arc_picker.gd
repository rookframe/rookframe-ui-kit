extends SceneTree
## ArcPicker in the native catalogue under every preview Theme and size.
## Pass `-- --capture-dir=/absolute/path` (windowed) to save review captures,
## and `--theme=<native|ledger|fantasy|cyberpunk>` to limit the matrix.
const Catalogue = preload("res://examples/components/catalogue.tscn")
const THEMES := {
	"native": "",
	"ledger": "res://rookframe/ui/themes/silkbound-ledger/theme.tres",
	"fantasy": "res://rookframe/ui/themes/fantasy/theme.tres",
	"cyberpunk": "res://rookframe/ui/themes/cyberpunk/theme.tres",
}
const VARIATIONS: Array[StringName] = [
	&"RookframeArcTrack", &"RookframeArcCategory", &"RookframeArcItem", &"RookframeArcWell",
	&"RookframeArcCaption", &"RookframeArcCaptionKicker", &"RookframeArcCaptionTitle",
]
var failures: Array[String] = []
var capture_dir := ""
var only := ""

func _initialize() -> void:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--capture-dir="):
			capture_dir = argument.trim_prefix("--capture-dir=")
		if argument.begins_with("--theme="):
			only = argument.trim_prefix("--theme=")
	if not capture_dir.is_empty(): DirAccess.make_dir_recursive_absolute(capture_dir)
	_run.call_deferred()

func _run() -> void:
	root.gui_embed_subwindows = true
	var catalogue = Catalogue.instantiate()
	root.add_child(catalogue)
	await settle()
	# The catalogue adopts the display scale; the matrix sizes are logical pixels.
	root.content_scale_factor = 1.0
	check(catalogue.show_page("arc_picker"), "Catalogue opens the Arc Picker page")
	await settle()
	var page = catalogue.current_page
	var picker: Control = page.find_children("*", "Control", true, false).filter(func(node): return node.scene_file_path.ends_with("navigation/arc_picker.tscn"))[0]
	# Captures show settled rings; the core suite covers the opening motion.
	picker.reduced_motion = true
	var stage: Control = picker.get_parent()
	# Opening focuses an entry; a page scroll that follows focus would move the stage under it.
	catalogue.content_scroll.follow_focus = false
	for theme_name in THEMES:
		if not only.is_empty() and theme_name != only:
			continue
		catalogue.select_theme("silkbound-ledger" if theme_name == "ledger" else theme_name)
		if theme_name != "native":
			var skin: Theme = load(THEMES[theme_name])
			for variation in VARIATIONS:
				check(skin.get_type_variation_base(variation) != &"", "%s maps %s" % [theme_name, variation])
		for canvas in [Vector2i(1920, 1080), Vector2i(1024, 768), Vector2i(844, 390)]:
			root.size = canvas
			await settle()
			check(page.get_combined_minimum_size().x <= page.size.x + 1, "%s page fits %s" % [theme_name, canvas])
			catalogue.content_scroll.ensure_control_visible(stage)
			await settle()
			picker.open_at(stage.size * Vector2(0.5, 0.62))
			await settle()
			_check_entries(picker, "%s %s" % [theme_name, canvas])
			var prefix := "%s-%dx%d" % [theme_name, canvas.x, canvas.y]
			await capture(prefix + "-open")
			var item: Control = picker.get_item_track().get_placed_entries()[2]
			item.grab_focus()
			await settle()
			await capture(prefix + "-focused")
			picker.select_category("ground")
			await settle()
			check(picker.get_item_track().can_scroll(1), "%s %s: a long category overflows" % [theme_name, canvas])
			await capture(prefix + "-overflow")
			picker.select_category("empty")
			await settle()
			await capture(prefix + "-empty")
			picker.select_category("masonry")
			picker.open_at(Vector2(stage.size.x - 24, 24))
			await settle()
			_check_entries(picker, "%s %s at the corner" % [theme_name, canvas])
			await capture(prefix + "-corner")
			catalogue.content_scroll.scroll_vertical += roundi(page.section_blocks[1].global_position.y - catalogue.content_scroll.global_position.y)
			await settle()
			await capture(prefix + "-track")
	catalogue.free()
	for failure in failures: push_error(failure)
	print("ARC_PICKER_SHOWCASE: %d failures" % failures.size())
	quit(0 if failures.is_empty() else 1)

func _check_entries(picker: Control, context: String) -> void:
	# The stage and the page scroll clip, so the picker fits what stays visible of both.
	var bounds := picker.get_viewport_rect()
	var node := picker.get_parent()
	while node is Control:
		if node.clip_contents:
			bounds = bounds.intersection(node.get_global_rect())
		node = node.get_parent()
	var rings := Rect2()
	var placed: Array = picker.get_category_track().get_placed_entries() + picker.get_item_track().get_placed_entries()
	for entry in placed:
		var minimum: Vector2 = entry.get_combined_minimum_size()
		check(minimum.x >= 44 and minimum.y >= 44, context + ": targets are at least 44 x 44")
		rings = entry.get_global_rect() if rings.size == Vector2.ZERO else rings.merge(entry.get_global_rect())
	# A visible area smaller than the rings (a phone-height stage under the page header) can only clamp.
	if rings.size.x > bounds.size.x or rings.size.y > bounds.size.y:
		check(bounds.has_point(picker.global_position), context + ": the picker origin stays visible when the rings cannot fit")
		return
	for entry in placed:
		check(bounds.encloses(entry.get_global_rect()), context + ": %s stays on screen" % entry.tooltip_text)


func check(condition: bool, message: String) -> void:
	if not condition: failures.append(message)

func settle() -> void:
	for frame in 6: await process_frame

func capture(name: String) -> void:
	if capture_dir.is_empty() or DisplayServer.get_name() == "headless": return
	await RenderingServer.frame_post_draw
	check(root.get_texture().get_image().save_png(capture_dir.path_join(name + ".png")) == OK, "Capture " + name)
