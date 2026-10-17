extends RefCounted

const Demo = preload("res://examples/components/pages/actions_forms/support.gd")

static func build(page) -> void:
	var required = page.section("Required choice", "The first enabled option starts selected. Exactly one choice remains active.")
	var group := ButtonGroup.new()
	var status = page.note(required, "Difficulty: Standard")
	for title in ["Standard", "Challenging", "Unavailable"]:
		var radio := Demo.checkbox(required, title, title == "Standard")
		radio.button_group = group
		radio.disabled = title == "Unavailable"
		radio.toggled.connect(func(enabled: bool):
			if enabled: status.text = "Difficulty: " + title
		)
	var optional = page.section("Optional choice", "No option starts selected. Activate the current choice again to clear it.")
	var optional_group := ButtonGroup.new()
	optional_group.allow_unpress = true
	var result = page.note(optional, "No preference.")
	for title in ["Morning", "Evening"]:
		var radio := Demo.checkbox(optional, title)
		radio.button_group = optional_group
		radio.toggled.connect(func(_enabled: bool):
			var selected := optional_group.get_pressed_button()
			result.text = "No preference." if selected == null else "Preferred: " + selected.text
		)
