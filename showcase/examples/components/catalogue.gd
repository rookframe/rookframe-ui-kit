extends Control
## Host-owned routes and navigation for individual production component specimens.
const Registry = preload("registry.gd")
const Page = preload("component_page.gd")
const Chrome = preload("catalogue_theme.gd")
const GROUP_COPY := {
	"Actions": "Trigger an action or choose a tool.",
	"Forms & selection": "Enter, validate, and select values.",
	"Navigation": "Move through retained views and content.",
	"Layout": "Arrange content across available space.",
	"Surfaces": "Frame tasks, reading, and grouped content.",
	"Data display": "Present records, facts, and collections.",
	"Feedback & overlays": "Explain status and support focused decisions."
}
var entries: Array[Dictionary] = []
var current_id := ""
var current_page: VBoxContainer
var reduced_motion := false
var search: LineEdit
var content_scroll: ScrollContainer
var sidebar: VBoxContainer
var navigation: ScrollContainer
var main: VBoxContainer
var nav_buttons: Dictionary = {}
var _groups: Dictionary = {}
var _empty: Label
var _count: Label
var _heading: Label
var _breadcrumb: Label
var _description: Label
var _page_host: VBoxContainer
var _outline: VBoxContainer
var _content_margin: MarginContainer
var _previous: Button
var _next: Button
var _menu: Button
var _compact := false
var _navigation_open := false
var _dark := false

func _ready() -> void:
	var window := get_window()
	var display_scale := maxf(1.0, DisplayServer.screen_get_scale(window.current_screen))
	# Keep the authored window size in logical units on high-DPI displays.
	window.size = Vector2i(Vector2(window.size) * display_scale / window.content_scale_factor)
	window.content_scale_factor = display_scale
	window.move_to_center()
	entries = Registry.entries()
	theme = Chrome.create()
	var background := PanelContainer.new()
	background.theme_type_variation = &"ShowcaseBackground"
	add_child(background)
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var padding := MarginContainer.new()
	background.add_child(padding)
	for edge in ["left", "right", "top", "bottom"]:
		padding.add_theme_constant_override("margin_" + edge, 16)
	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 12)
	padding.add_child(layout)
	var top := HBoxContainer.new()
	layout.add_child(top)
	_menu = _button(top, "Components", _toggle_navigation)
	var brand := _label("ROOKFRAME", 20)
	brand.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(brand)
	var motion := CheckButton.new()
	motion.text = "Reduced motion"
	motion.custom_minimum_size.y = 44
	motion.toggled.connect(set_reduced_motion)
	top.add_child(motion)
	_button(top, "Light / dark", func() -> void:
		_dark = not _dark
		theme = Chrome.create(_dark))
	layout.add_child(HSeparator.new())
	var body := HBoxContainer.new()
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 24)
	layout.add_child(body)
	_build_sidebar(body)
	main = VBoxContainer.new()
	main.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_child(main)
	var route_bar := HBoxContainer.new()
	main.add_child(route_bar)
	_breadcrumb = _label("Components", 14)
	_breadcrumb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	route_bar.add_child(_breadcrumb)
	_previous = _button(route_bar, "Previous", func() -> void: _adjacent(-1))
	_next = _button(route_bar, "Next", func() -> void: _adjacent(1))
	content_scroll = ScrollContainer.new()
	content_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	content_scroll.follow_focus = true
	content_scroll.focus_mode = Control.FOCUS_ALL
	content_scroll.get_v_scroll_bar().custom_minimum_size.x = 16
	main.add_child(content_scroll)
	_content_margin = MarginContainer.new()
	_content_margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_content_margin.add_theme_constant_override("margin_right", 12)
	_content_margin.add_theme_constant_override("margin_bottom", 32)
	content_scroll.add_child(_content_margin)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 18)
	_content_margin.add_child(content)
	_heading = _label("Components", 36)
	content.add_child(_heading)
	_description = _label("", 18)
	content.add_child(_description)
	_page_host = VBoxContainer.new()
	_page_host.add_theme_constant_override("separation", 28)
	content.add_child(_page_host)
	_outline = VBoxContainer.new()
	_outline.custom_minimum_size.x = 170
	body.add_child(_outline)
	resized.connect(_responsive)
	_responsive()
	var initial := ""
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--component="):
			initial = argument.trim_prefix("--component=")
	show_page(initial)

func _build_sidebar(parent: Node) -> void:
	sidebar = VBoxContainer.new()
	sidebar.custom_minimum_size.x = 236
	parent.add_child(sidebar)
	search = LineEdit.new()
	search.placeholder_text = "Search components…"
	search.accessibility_name = "Search components"
	search.tooltip_text = "Search by name, category, or purpose · Ctrl/Cmd+K"
	search.custom_minimum_size.y = 44
	search.text_changed.connect(filter_navigation)
	search.text_submitted.connect(_open_first_match)
	sidebar.add_child(search)
	_count = _label("", 13)
	sidebar.add_child(_count)
	navigation = ScrollContainer.new()
	navigation.size_flags_vertical = Control.SIZE_EXPAND_FILL
	navigation.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	navigation.follow_focus = true
	sidebar.add_child(navigation)
	var list := VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.add_theme_constant_override("separation", 18)
	navigation.add_child(list)
	var overview := _button(list, "All components", show_page.bind(""))
	overview.theme_type_variation = &"ShowcaseNav"
	overview.alignment = HORIZONTAL_ALIGNMENT_LEFT
	for category in Registry.CATEGORIES:
		var group := VBoxContainer.new()
		group.add_theme_constant_override("separation", 2)
		list.add_child(group)
		_groups[category] = group
		var label := _label(category, 14)
		label.add_theme_color_override("font_color", Color("888890"))
		group.add_child(label)
		for entry in entries:
			if entry.category != category:
				continue
			var button := _button(group, entry.title, show_page.bind(entry.id))
			button.theme_type_variation = &"ShowcaseNav"
			button.alignment = HORIZONTAL_ALIGNMENT_LEFT
			button.toggle_mode = true
			button.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
			button.tooltip_text = entry.title
			button.accessibility_name = entry.title + ", " + category
			nav_buttons[entry.id] = button
	_empty = _label("No components found. Try a name such as Button or a group such as Surfaces.")
	list.add_child(_empty)
	filter_navigation("")

func filter_navigation(query: String) -> void:
	var count := 0
	for entry in entries:
		var matches := Registry.matches(entry, query)
		nav_buttons[entry.id].visible = matches
		if matches:
			count += 1
	for category in _groups:
		var any := false
		for entry in entries:
			if entry.category == category and nav_buttons[entry.id].visible:
				any = true
		_groups[category].visible = any
	_count.text = "%d components" % count
	_empty.visible = count == 0

func show_page(id: String) -> bool:
	if id in Registry.BUTTON_ALIASES:
		id = "button"
	var entry: Dictionary = {}
	for item in entries:
		if item.id == id:
			entry = item
			break
	if not id.is_empty() and entry.is_empty():
		return false
	var return_to_content := _compact and _navigation_open
	_clear(_page_host)
	_clear(_outline)
	current_page = null
	current_id = id
	for key in nav_buttons:
		nav_buttons[key].set_pressed_no_signal(key == id)
	content_scroll.scroll_vertical = 0
	if id.is_empty():
		_heading.text = "Components"
		_description.text = "Explore the building blocks of Rookframe. Choose a component to try its variants, interaction states, and composition patterns."
		_breadcrumb.text = "Component library"
		_build_overview()
	else:
		_heading.text = entry.title
		_description.text = entry.description
		_breadcrumb.text = "Components  /  " + entry.category
		current_page = Page.new()
		current_page.entry = entry
		current_page.reduced_motion = reduced_motion
		current_page.add_theme_constant_override("separation", 28)
		_page_host.add_child(current_page)
		var implementation = load(entry.script)
		if implementation != null:
			implementation.build(current_page)
		_apply_motion(current_page)
		_build_outline()
	var index := _index()
	_previous.disabled = index <= 0
	_next.disabled = index >= entries.size() - 1 or entries.is_empty()
	_navigation_open = false
	_responsive()
	content_scroll.accessibility_name = _heading.text + " examples"
	if return_to_content:
		content_scroll.grab_focus()
	return true

func _build_overview() -> void:
	for category in Registry.CATEGORIES:
		var group_entries: Array[Dictionary] = []
		for entry in entries:
			if entry.category == category:
				group_entries.append(entry)
		if group_entries.is_empty():
			continue
		var group := VBoxContainer.new()
		_page_host.add_child(group)
		group.add_child(_label("%s  ·  %d" % [category, group_entries.size()], 23))
		group.add_child(_label(GROUP_COPY[category]))
		var links := HFlowContainer.new()
		links.add_theme_constant_override("h_separation", 8)
		links.add_theme_constant_override("v_separation", 8)
		group.add_child(links)
		for entry in group_entries:
			_button(links, entry.title, show_page.bind(entry.id))

func _build_outline() -> void:
	_outline.add_child(_label("On this page", 14))
	for index in current_page.section_titles.size():
		var button := _button(_outline, current_page.section_titles[index], func() -> void:
			var block: Control = current_page.section_blocks[index]
			content_scroll.scroll_vertical = int(block.global_position.y - _content_margin.global_position.y))
		button.theme_type_variation = &"ShowcaseNav"
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		button.tooltip_text = current_page.section_titles[index]

func _responsive() -> void:
	if not is_instance_valid(sidebar):
		return
	_compact = size.x < 1000
	_menu.visible = _compact
	sidebar.visible = not _compact or _navigation_open
	sidebar.size_flags_horizontal = Control.SIZE_EXPAND_FILL if _compact else Control.SIZE_FILL
	main.visible = not _compact or not _navigation_open
	_outline.visible = size.x >= 1500 and not current_id.is_empty()
	_heading.add_theme_font_size_override("font_size", 28 if size.y < 500 else 36)

func _toggle_navigation() -> void:
	_navigation_open = not _navigation_open
	_responsive()
	if _navigation_open:
		search.grab_focus()

func _open_first_match(query: String) -> void:
	for entry in entries:
		if Registry.matches(entry, query):
			show_page(entry.id)
			return

func _index() -> int:
	for index in entries.size():
		if entries[index].id == current_id:
			return index
	return -1

func _adjacent(direction: int) -> void:
	var index := clampi(_index() + direction, 0, entries.size() - 1)
	if not entries.is_empty():
		show_page(entries[index].id)

func set_reduced_motion(value: bool) -> void:
	reduced_motion = value
	if is_instance_valid(current_page):
		_apply_motion(current_page)

func _apply_motion(node: Node) -> void:
	for property in node.get_property_list():
		if property.name == "reduced_motion":
			node.set("reduced_motion", reduced_motion or node.get_meta("fixed_reduced_motion", false))
	for child in node.get_children():
		_apply_motion(child)

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_K and (event.ctrl_pressed or event.meta_pressed):
			_navigation_open = true
			_responsive()
			search.grab_focus()
			search.select_all()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_ESCAPE and _compact and _navigation_open:
			_navigation_open = false
			_responsive()
			_menu.grab_focus()
			get_viewport().set_input_as_handled()

func _clear(parent: Node) -> void:
	for child in parent.get_children():
		parent.remove_child(child)
		child.queue_free()

func _label(copy: String, font_size: int = 16) -> Label:
	var result := Label.new()
	result.text = copy
	result.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	result.add_theme_font_size_override("font_size", font_size)
	return result

func _button(parent: Node, copy: String, action: Callable) -> Button:
	var result := Button.new()
	result.text = copy
	result.custom_minimum_size = Vector2(44, 44)
	result.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	result.pressed.connect(action)
	parent.add_child(result)
	return result
