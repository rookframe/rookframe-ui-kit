extends RefCounted

const Demo = preload("res://examples/components/pages/layout_surfaces/demo.gd")

static func build(page) -> void:
	for bottom in [false, true]:
		var body = page.section("Bottom tabs" if bottom else "Retained panels", "Edit a value and change tabs. Returning preserves the editor state; the locked tab cannot activate.")
		var tabs := TabContainer.new()
		tabs.custom_minimum_size.y = 180
		tabs.tabs_position = TabContainer.POSITION_BOTTOM if bottom else TabContainer.POSITION_TOP
		body.add_child(tabs)
		for title in ["Overview", "Notes", "Locked"]:
			var panel := VBoxContainer.new()
			panel.name = title
			tabs.add_child(panel)
			page.note(panel, title + " panel")
			Demo.editor(panel, "My " + title.to_lower(), title + " value")
		tabs.set_tab_disabled(2, true)
