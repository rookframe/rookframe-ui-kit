extends SceneTree
## The Design tokens page under every preview Theme: each token appears with the
## selected theme's value, and a theme switch updates the retained page.
## Pass `-- --capture-dir=/absolute/path` (windowed) to save review captures,
## and `--theme=<native|silkbound-ledger|fantasy|cyberpunk>` to limit the matrix.
const Catalogue = preload("res://examples/components/catalogue.tscn")
const Tokens = preload("res://rookframe/ui/themes/design_tokens.gd")
const NEUTRAL = preload("res://rookframe/ui/themes/neutral_tokens.tres")
const THEMES := ["native", "silkbound-ledger", "fantasy", "cyberpunk"]
var failures: Array[String] = []
var capture_dir := ""
var only := ""

func _initialize() -> void:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--capture-dir="):
			capture_dir = argument.trim_prefix("--capture-dir=")
		if argument.begins_with("--theme="):
			only = argument.trim_prefix("--theme=")
	if not capture_dir.is_empty():
		DirAccess.make_dir_recursive_absolute(capture_dir)
	_run.call_deferred()

func _run() -> void:
	root.gui_embed_subwindows = true
	var catalogue = Catalogue.instantiate()
	root.add_child(catalogue)
	await settle()
	# The catalogue adopts the display scale; the matrix sizes are logical pixels.
	root.content_scale_factor = 1.0
	check(catalogue.show_page("design_tokens"), "Catalogue opens the Design tokens page")
	await settle()
	var page = catalogue.current_page
	# Captures show settled markers; motion itself is covered by the reduced-motion check.
	catalogue.set_reduced_motion(true)
	var motion: Array = page.find_children("*", "MarginContainer", true, false).filter(func(node): return "reduced_motion" in node)
	check(not motion.is_empty() and motion.all(func(node): return node.reduced_motion), "Reduced motion reaches every motion sample")
	for theme_name in THEMES:
		if not only.is_empty() and theme_name != only:
			continue
		check(catalogue.select_theme(theme_name), "Catalogue selects " + theme_name)
		await settle()
		check(catalogue.current_page == page, "%s: the theme switch keeps the page" % theme_name)
		var source: Theme = NEUTRAL if theme_name == "native" else catalogue.PREVIEW_THEMES[theme_name]
		_check_names(page, theme_name)
		_check_values(page, theme_name, source)
		for canvas in [Vector2i(1920, 1080), Vector2i(1024, 768), Vector2i(844, 390)]:
			root.size = canvas
			await settle()
			check(page.get_combined_minimum_size().x <= page.size.x + 1, "%s page fits %s" % [theme_name, canvas])
			await _capture_page(catalogue, "%s-%dx%d" % [theme_name, canvas.x, canvas.y])
	catalogue.free()
	await settle()
	print("TOKEN_REFERENCE: %d failures" % failures.size())
	quit(0 if failures.is_empty() else 1)

## Every token name appears in the page text.
func _check_names(page: Control, theme_name: String) -> void:
	var words := {}
	for label in page.find_children("*", "Label", true, false):
		for word in label.text.split(" ", false):
			words[word] = true
	for data_type in Tokens.data_types():
		for token in Tokens.names(data_type):
			check(words.has(String(token)), "%s: the page shows %s" % [theme_name, token])

## Each color swatch shows the value the selected theme supplies.
func _check_values(page: Control, theme_name: String, source: Theme) -> void:
	var swatches := 0
	for value in page.find_children("TokenValue", "Label", true, false):
		var token := StringName(value.get_parent().get_node("TokenName").text)
		if not Tokens.COLORS.has(token):
			continue
		var color := source.get_color(token, Tokens.TYPE)
		check(value.text == "#" + color.to_html(color.a < 1.0), "%s: %s shows %s, not %s" % [theme_name, token, color.to_html(), value.text])
		swatches += 1
	check(swatches == Tokens.COLORS.size(), "%s: one swatch per color token (%d)" % [theme_name, swatches])

## Captures the page from its heading to its end, one viewport at a time.
func _capture_page(catalogue: Control, name: String) -> void:
	if capture_dir.is_empty() or DisplayServer.get_name() == "headless":
		return
	var scroll: ScrollContainer = catalogue.content_scroll
	scroll.scroll_vertical = 0
	var index := 0
	while true:
		await settle()
		await RenderingServer.frame_post_draw
		var file := capture_dir.path_join("%s-%02d.png" % [name, index])
		check(root.get_texture().get_image().save_png(file) == OK, "Capture " + file)
		var end := int(scroll.get_v_scroll_bar().max_value - scroll.size.y)
		if scroll.scroll_vertical >= end or index >= 60:
			break
		scroll.scroll_vertical = mini(scroll.scroll_vertical + int(scroll.size.y * 0.9), end)
		index += 1

func check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
		push_error(message)

func settle() -> void:
	for frame in 6:
		await process_frame
