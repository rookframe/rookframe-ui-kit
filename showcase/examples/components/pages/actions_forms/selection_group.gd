extends RefCounted

const Demo = preload("res://examples/components/pages/actions_forms/support.gd")

static func build(page) -> void:
	var required = page.section("Required choice", "The first enabled option starts selected. Exactly one choice remains active.")
	var group := preload("res://rookframe/ui/components/forms/selection_group.tres").duplicate() as ButtonGroup
	var status = page.note(required, "Difficulty: Standard")
	for title in ["Standard", "Challenging", "Unavailable"]:
		var radio := Demo.checkbox(required, title, title == "Standard")
		radio.button_group = group
		radio.disabled = title == "Unavailable"
		radio.toggled.connect(func(enabled: bool):
			if enabled: status.text = "Difficulty: " + title
		)
	var optional = page.section("Optional choice", "No option starts selected. Activate the current choice again to clear it.")
	var optional_group := preload("res://rookframe/ui/components/forms/selection_group.tres").duplicate() as ButtonGroup
	optional_group.allow_unpress = true
	var result = page.note(optional, "No preference.")
	for title in ["Morning", "Evening"]:
		var radio := Demo.checkbox(optional, title)
		radio.button_group = optional_group
		radio.toggled.connect(func(_enabled: bool):
			var selected := optional_group.get_pressed_button()
			result.text = "No preference." if selected == null else "Preferred: " + selected.text
		)

	var main = page.section("Exclusive display mode", "One shared ButtonGroup keeps exactly one mode active.")
	var toggle_group := preload("res://rookframe/ui/components/forms/selection_group.tres").duplicate() as ButtonGroup
	var controls = page.flow(main)
	var toggle_status = page.note(main, "Display: List")
	for title in ["List", "Grid", "Compact"]:
		var toggle = page.scene("res://rookframe/ui/components/actions/toggle.tscn", controls, {"text": title})
		toggle.toggle_mode = true
		toggle.button_group = toggle_group
		toggle.button_pressed = title == "List"
		toggle.toggled.connect(func(selected: bool):
			if selected: toggle_status.text = "Display: " + title
		)
	var other = page.section("Multiple independent options", "Without a shared group, several options can remain pressed.")
	var flags = page.flow(other)
	var state := {"Bold": false, "Italic": false, "Underline": false}
	var toggle_result = page.note(other, "No formatting selected.")
	for title in ["Bold", "Italic", "Underline"]:
		var toggle = page.scene("res://rookframe/ui/components/actions/toggle.tscn", flags, {"text": title})
		toggle.toggle_mode = true
		toggle.toggled.connect(func(selected: bool):
			state[title] = selected
			var active: PackedStringArray = []
			for key in state:
				if state[key]: active.append(key)
			toggle_result.text = "No formatting selected." if active.is_empty() else " + ".join(active)
		)
