extends RefCounted
## Shared specimen wiring; each page supplies its own examples and public resource.

static func checkbox(parent: Node, title: String, selected: bool = false) -> CheckBox:
	var control := preload("res://rookframe/ui/components/forms/checkbox.tscn").instantiate() as CheckBox
	control.text = title
	control.button_pressed = selected
	control.custom_minimum_size.y = 44
	parent.add_child(control)
	return control

static func line(parent: Node, title: String, value: String = "") -> LineEdit:
	var control := preload("res://rookframe/ui/components/forms/input.tscn").instantiate() as LineEdit
	control.accessibility_name = title
	control.text = value
	control.custom_minimum_size.y = 44
	control.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(control)
	return control

static func text(parent: Node, title: String, value: String = "") -> TextEdit:
	var control := preload("res://rookframe/ui/components/forms/textarea.tscn").instantiate() as TextEdit
	control.accessibility_name = title
	control.text = value
	control.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	control.custom_minimum_size.y = 150
	control.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(control)
	return control

static func input_examples(page, path: String, multiline: bool, task: bool) -> void:
	var editable = page.section("Edit and validate", "Enter a value, then commit it. Validation and saved values belong to this example.")
	var properties := {"label_text": "Journal entry" if multiline else "Character name", "placeholder": "Write a memory…" if multiline else "e.g. Elara", "help_text": "Leave the editor to commit." if multiline else "Press Enter to commit. Use at least three characters."}
	var field = page.scene(path, editable, properties)
	var status = page.note(editable, "No changes committed.")
	field.value_changed.connect(func(value: String): status.text = "%d characters in the draft." % value.length())
	field.value_committed.connect(func(value: String):
		field.set_error("Add at least three characters." if value.strip_edges().length() < 3 else "")
		status.text = "Saved locally: " + value if field.error_text.is_empty() else "The draft needs attention."
	)
	var controls = page.flow(editable)
	page.button(controls, "Focus editor", field.focus_editor)
	page.button(controls, "Show error", func(): field.set_error("This example value is already in use."))
	page.button(controls, "Clear error", func(): field.set_error(""))
	var states = page.section("Read-only and density" if task else "Read-only value", "Selection and copy remain available while editing is locked.")
	var locked = page.scene(path, states, {"label_text": "Archived note" if multiline else "Record identifier", "value": "The northern gate remained open through winter." if multiline else "CHAR-0142", "editable": false, "help_text": "Unlock to try the same field as an editable draft."})
	var unlock := checkbox(page.flow(states), "Allow editing")
	unlock.toggled.connect(func(enabled: bool): locked.editable = enabled)
	if task:
		var compact := checkbox(page.flow(states), "Compact density")
		compact.toggled.connect(func(enabled: bool): field.compact = enabled; locked.compact = enabled)

static func shell_scene(page, path: String, parent: Node, properties: Dictionary = {}) -> Node:
	return page.scene(path, parent, properties)

static func menu_button_examples(page, path: String, title: String, dangerous: bool = false) -> void:
	var main = page.section("Activation", "Try pointer activation, Tab focus and Enter or Space.")
	var status = page.note(main, "No action requested.")
	var control = shell_scene(page, path, main, {"text": title})
	control.pressed.connect(func(): status.text = "Confirmation requested for: " + title if dangerous else "Requested: " + title)
	var settings = page.flow(main)
	page.button(settings, "Focus action", control.grab_focus)
	var disabled := checkbox(settings, "Disable action")
	disabled.toggled.connect(func(enabled: bool): control.disabled = enabled)
	var compact := checkbox(settings, "Compact density")
	compact.toggled.connect(control.set_compact)
	var other = page.section("Disabled state", "Unavailable actions keep a readable label and do not activate.")
	shell_scene(page, path, other, {"text": "Unavailable action", "disabled": true})
	page.note(other, "Try the enabled example above to compare hover, focus and pressed feedback.")
