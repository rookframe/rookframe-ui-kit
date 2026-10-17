extends RefCounted

static func build(page) -> void:
	var main = page.section("Exclusive display mode", "One shared ButtonGroup keeps exactly one mode active.")
	var group := ButtonGroup.new()
	var controls = page.flow(main)
	var status = page.note(main, "Display: List")
	for title in ["List", "Grid", "Compact"]:
		var toggle = page.button(controls, title)
		toggle.toggle_mode = true
		toggle.button_group = group
		toggle.button_pressed = title == "List"
		toggle.toggled.connect(func(selected: bool):
			if selected: status.text = "Display: " + title
		)
	var other = page.section("Multiple independent options", "Without a shared group, several options can remain pressed.")
	var flags = page.flow(other)
	var state := {"Bold": false, "Italic": false, "Underline": false}
	var result = page.note(other, "No formatting selected.")
	for title in ["Bold", "Italic", "Underline"]:
		var toggle = page.button(flags, title)
		toggle.toggle_mode = true
		toggle.toggled.connect(func(selected: bool):
			state[title] = selected
			var active: PackedStringArray = []
			for key in state:
				if state[key]: active.append(key)
			result.text = "No formatting selected." if active.is_empty() else " + ".join(active)
		)
