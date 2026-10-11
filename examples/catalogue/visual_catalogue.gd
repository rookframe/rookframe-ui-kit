extends Control
## Standalone samples of the components implemented in the host's menu/settings.
const THEMES: Array[Theme] = [
	preload("res://rookframe/ui/menu/cyberpunk/CyberpunkTheme.tres"),
	preload("res://rookframe/ui/menu/MenuTheme.tres"),
]
var compact := false


func _ready() -> void:
	%OldCatalogue.pressed.connect(_open_old_catalogue)
	%ThemeChoice.item_selected.connect(select_theme)
	%DensityChoice.item_selected.connect(func(index: int) -> void: set_compact(index == 1))
	%PageChoice.item_selected.connect(select_page)
	%ThemeChoice.accessibility_name = "Theme"
	%DensityChoice.accessibility_name = "Density"
	%PageChoice.accessibility_name = "Component page"
	%Editor.feedback.connect(func(message: String) -> void: %Feedback.text = message)
	resized.connect(_fit_catalogue)
	for button: Button in find_children("*", "Button", true, false):
		if %Editor.is_ancestor_of(button):
			continue
		button.pressed.connect(func() -> void:
			%Feedback.text = "%s pressed." % (button.text if not button.text.is_empty() else "Navigation")
		)
	select_theme(0)
	select_page(0)
	_fit_catalogue()


func select_theme(index: int) -> void:
	theme = THEMES[index]
	%ThemeChoice.select(index)
	_apply_density()


func set_compact(enabled: bool) -> void:
	compact = enabled
	%DensityChoice.select(1 if enabled else 0)
	_apply_density()


func select_page(index: int) -> void:
	%PageChoice.select(index)
	for page: Control in %Pages.get_children():
		page.visible = page.get_index() == index
	%Scroll.scroll_vertical = 0


func _apply_density() -> void:
	if not is_node_ready():
		return
	for control: Control in find_children("*", "Control", true, false):
		var usage := String(control.theme_type_variation).trim_suffix("__compact")
		if control is OptionButton and control.has_method("set_compact"):
			control.set_compact(compact)
		elif control.has_method("set_compact"):
			control.set_compact(compact)
			# The host's Main Menu uses these regular/short button heights.
			if control.get_script() == preload("res://rookframe/ui/menu/menu_button.gd"):
				control.custom_minimum_size.y = 44 if compact else 64 if control.usage == &"menu.button.primary" else 60
		elif theme.get_type_variation_base(usage + "__compact") != &"":
			control.theme_type_variation = usage + ("__compact" if compact else "")
		if control is OptionButton:
			if not control.has_method("set_compact"):
				control.get_popup().theme_type_variation = &"settings_popup"
				control.custom_minimum_size.y = _metric("control_height")
			if %Settings.is_ancestor_of(control):
				control.custom_minimum_size.x = _metric("choice_width")
		if control is ScrollContainer:
			control.get_v_scroll_bar().theme_type_variation = &"settings_scrollbar"
	for action: Button in %Settings.get_node("Actions").get_children():
		action.custom_minimum_size = Vector2(_metric("action_width"), _metric("control_height"))
	for cell: Control in %Typography.get_node("Icons").get_children():
		# Fantasy deliberately has no menu-action pictograms.
		cell.visible = theme.has_icon("image", cell.get_node("Image").theme_type_variation)
	for sample in %Menu.get_node("Buttons/Surface/States").get_children():
		sample.configure(theme, compact)
	%Editor.configure(theme, compact)
	# Match the host's existing action-row styling after its native ready hook.
	var row := %Settings.get_node("Navigation") as Button
	row.theme_type_variation = "settings_navigation" + ("__compact" if compact else "")
	row.custom_minimum_size.y = _metric("category_height")
	for path in ["Content/Copy/Title", "Content/Copy/Description", "Content/Action"]:
		var label := row.get_node(path) as Label
		label.remove_theme_font_size_override("font_size")
		label.theme_type_variation = ("settings_help" if path.ends_with("Description") else "settings_label") + ("__compact" if compact else "")


func _metric(name: String) -> int:
	return get_theme_constant(name + ("_short" if compact else ""), &"settings_layout")


func _fit_catalogue() -> void:
	var narrow := size.x < 1000
	%Header.vertical = narrow
	%Menu.vertical = narrow
	%Settings.get_node("Language").vertical = narrow
	%Settings.get_node("Quality").vertical = narrow
	%Typography.get_node("Columns").vertical = narrow


func _open_old_catalogue() -> void:
	var old := load("res://examples/catalogue/legacy_catalogue.tscn").instantiate() as Control
	add_child(old)
	$Frame.hide()
	old.return_requested.connect(func() -> void:
		old.queue_free()
		$Frame.show()
		%OldCatalogue.grab_focus()
	)
	old.get_node("%CurrentCatalogue").grab_focus()
