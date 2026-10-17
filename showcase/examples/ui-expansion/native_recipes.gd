extends VBoxContainer
## Synthetic Settings and character-detail recipes. All controls are production
## resources or stock Godot nodes; the example owns every synthetic action.
const UI := "res://rookframe/ui/"
var controls: Dictionary = {}
var actions: Array[String] = []
var include_settings := true
var include_details := true

func _ready() -> void:
	if include_settings: _settings()
	if include_details: _details()

func _label(copy: String, role := &"RookframeBody") -> Label:
	var label := Label.new()
	label.text = copy
	label.theme_type_variation = role
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return label

func _action(copy: String, id: String) -> Button:
	var button := Button.new()
	button.text = copy
	button.accessibility_name = copy
	button.custom_minimum_size = Vector2(44, 44)
	button.pressed.connect(func(): actions.append(id))
	controls[id] = button
	return button

func _settings() -> void:
	add_child(_label("Settings", &"RookframeHeading"))
	var select := OptionButton.new()
	select.custom_minimum_size.y = 44
	select.accessibility_name = "Quality"
	select.add_item("Balanced", 10)
	select.add_item("High", 30)
	select.add_item("Unavailable", 70)
	select.set_item_disabled(2, true)
	select.get_popup().allow_search = true
	select.item_selected.connect(func(index: int): actions.append("quality:%d" % select.get_item_id(index)))
	add_child(select)
	controls.select = select
	for required in [true, false]:
		var group := ButtonGroup.new()
		group.allow_unpress = not required
		add_child(_label("Required choice" if required else "Optional choice", &"RookframeLabel"))
		for i in 3:
			var choice := CheckBox.new()
			choice.text = ["Local", "Shared", "Unavailable"][i]
			choice.custom_minimum_size = Vector2(44, 44)
			choice.button_group = group
			choice.disabled = i == 2
			choice.button_pressed = required and i == 0
			add_child(choice)
		controls["radio_required" if required else "radio_optional"] = group
	var checkbox := CheckBox.new()
	checkbox.text = "Show item names"
	checkbox.custom_minimum_size.y = 44
	add_child(checkbox)
	controls.checkbox = checkbox
	var setting := CheckButton.new()
	setting.text = "Enable ambient sound"
	setting.custom_minimum_size.y = 44
	add_child(setting)
	controls.switch = setting
	var toggles := HFlowContainer.new()
	add_child(toggles)
	for copy in ["Favorite", "Equipped", "Tracked"]:
		var toggle := _action(copy, copy.to_lower())
		toggle.toggle_mode = true
		toggles.add_child(toggle)
	var actions_bar = load(UI + "components/layout/action_bar.tscn").instantiate()
	add_child(actions_bar)
	actions_bar.get_leading_slot().add_child(_action("Reset", "reset"))
	actions_bar.get_trailing_slot().add_child(_action("Apply", "apply"))
	var menu := MenuButton.new()
	menu.text = "Actions"
	menu.custom_minimum_size.y = 44
	menu.get_popup().add_item("Duplicate", 20)
	menu.get_popup().add_item("Delete", 40)
	menu.get_popup().id_pressed.connect(func(id: int): actions.append("menu:%d" % id))
	add_child(menu)
	controls.dropdown = menu
	var context := PopupMenu.new()
	context.add_item("Inspect", 12)
	context.add_item("Unavailable", 18)
	context.set_item_disabled(1, true)
	add_child(context)
	var source := _action("Item actions", "context_open")
	add_child(source)
	var open_context := func():
		context.popup(Rect2i(source.get_screen_position() + Vector2(0, source.size.y), Vector2i(220, 0)))
		context.set_focused_item(0)
	source.pressed.connect(open_context)
	source.gui_input.connect(func(event: InputEvent):
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			open_context.call()
			source.accept_event())
	context.popup_hide.connect(func():
		if source.is_visible_in_tree(): source.grab_focus())
	context.id_pressed.connect(func(id: int): actions.append("context:%d" % id))
	controls.context = context
	var tabs := TabContainer.new()
	tabs.custom_minimum_size.y = 140
	add_child(tabs)
	for copy in ["General", "Notes", "Locked"]:
		var panel := VBoxContainer.new()
		panel.name = copy
		tabs.add_child(panel)
		var editor := LineEdit.new()
		editor.text = "Retained " + copy
		editor.accessibility_name = copy
		editor.custom_minimum_size.y = 44
		panel.add_child(editor)
	tabs.set_tab_disabled(2, true)
	controls.tabs = tabs
	for single in [true, false]:
		var group := FoldableGroup.new() if single else null
		for i in 2:
			var fold := FoldableContainer.new()
			fold.title = ("Accordion" if single else "Independent section") + " %d" % (i + 1)
			fold.foldable_group = group
			fold.folded = i != 0
			var editor := LineEdit.new()
			editor.text = "Content survives disclosure"
			editor.custom_minimum_size.y = 44
			fold.add_child(editor)
			add_child(fold)
	for path in ["text_field", "text_area", "search_field"]:
		var editor = load(UI + "components/forms/" + path + ".tscn").instantiate()
		add_child(editor)
		editor.label_text = path.capitalize()
		editor.value = "Native editable content"
		controls[path] = editor
	var slider := HSlider.new()
	slider.min_value = 0
	slider.max_value = 100
	slider.step = 5
	slider.value = 50
	slider.custom_minimum_size.y = 44
	slider.accessibility_name = "Music volume, percent, zero to one hundred"
	add_child(slider)
	controls.slider = slider
	var number := SpinBox.new()
	number.min_value = 0
	number.max_value = 100
	number.step = 1
	number.suffix = "kg"
	number.custom_minimum_size.y = 44
	number.accessibility_name = "Capacity in kilograms"
	add_child(number)
	controls.number = number

func _details() -> void:
	add_child(HSeparator.new())
	add_child(_label("Character details", &"RookframeHeading"))
	var avatar := HBoxContainer.new()
	var initials := _label("AR", &"RookframeTitle")
	initials.accessibility_name = "Archivist Rowan"
	avatar.add_child(initials)
	avatar.add_child(_label("Archivist Rowan", &"RookframeIdentity"))
	add_child(avatar)
	var badge = load(UI + "components/data/badge.tscn").instantiate()
	badge.label_text = "Ready"
	add_child(badge)
	for data in [["Health", 75, 100], ["Mana", 20, 50], ["Loading assets", 8, 10]]:
		add_child(_label("%s: %d / %d" % data, &"RookframeLabel"))
		var meter := ProgressBar.new()
		meter.max_value = data[2]
		meter.value = clampf(data[1], 0, data[2])
		meter.accessibility_name = "%s: %d / %d" % data
		add_child(meter)
	var notice = load(UI + "components/feedback/notice.tscn").instantiate()
	notice.title = "Equipment ready"
	notice.description = "Inspect the item before equipping it."
	add_child(notice)
	var busy = load(UI + "components/feedback/task_state.tscn").instantiate()
	busy.state = 0
	busy.title = "Loading inventory"
	busy.reduced_motion = true
	add_child(busy)
	controls.busy = busy
	var empty = load(UI + "components/feedback/task_state.tscn").instantiate()
	empty.title = "No items yet"
	empty.description = "Add an item to your inventory. Filtered results use a separate no-match explanation."
	add_child(empty)
	empty.get_action_slot().add_child(_action("Add item", "add_item"))
	var dialog = load(UI + "components/overlays/dialog.tscn").instantiate()
	dialog.visible = false
	dialog.heading = "Discard changes?"
	dialog.confirm_label = "Discard"
	dialog.cancel_label = "Keep editing"
	add_child(dialog)
	dialog.confirmed.connect(func(): actions.append("confirmed"))
	dialog.cancelled.connect(func(): actions.append("cancelled"))
	var open := _action("Discard changes…", "dialog_open")
	open.tooltip_text = "Review the confirmation before discarding changes."
	open.pressed.connect(dialog.open_dialog)
	add_child(open)
	controls.dialog = dialog
	var table := Tree.new()
	table.columns = 3
	table.column_titles_visible = true
	table.hide_root = true
	table.custom_minimum_size.y = 180
	for i in 3: table.set_column_title(i, ["Item", "Quantity", "Weight"][i])
	var root := table.create_item()
	for i in 4:
		var row := table.create_item(root)
		row.set_text(0, "Long descriptive item name %d" % i)
		row.set_tooltip_text(0, row.get_text(0))
		row.set_text(1, str(i + 1))
		row.set_text(2, "%d kg" % (i + 2))
		row.set_text_alignment(1, HORIZONTAL_ALIGNMENT_RIGHT)
		row.set_text_alignment(2, HORIZONTAL_ALIGNMENT_RIGHT)
	add_child(table)
	controls.table = table
	for crop in [false, true]:
		var ratio := AspectRatioContainer.new()
		ratio.ratio = 16.0 / 9.0
		ratio.custom_minimum_size.y = 120
		var image := TextureRect.new()
		image.texture = load(UI + "icons/sigil.svg")
		image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED if crop else TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		ratio.add_child(image)
		add_child(ratio)
