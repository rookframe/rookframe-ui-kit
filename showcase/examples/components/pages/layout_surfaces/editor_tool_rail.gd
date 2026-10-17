extends RefCounted

const Demo = preload("res://examples/components/pages/layout_surfaces/demo.gd")

static func build(page) -> void:
	for horizontal in [false, true]:
		var body = page.section("Horizontal rail" if horizontal else "Vertical rail", "One selected tool is retained through native ButtonGroup behavior.")
		var rail = Demo.component(page, "editor/EditorToolRail.tscn", body)
		rail.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		var tools = rail.get_node("Tools")
		tools.vertical = not horizontal
		var group := ButtonGroup.new()
		var status = page.note(body, "Selected: Move")
		for index in 3:
			var title: String = ["Move", "Inspect", "Draw"][index]
			var tool = Demo.component(page, "editor/EditorToolButton.tscn", tools, {"compact": true, "toggle_mode": true, "button_group": group, "button_pressed": index == 0, "icon": load("res://rookframe/ui/icons/" + ["crosshair", "search", "edit"][index] + ".svg"), "accessibility_name": title, "tooltip_text": title})
			tool.pressed.connect(func(): status.text = "Selected: " + title)
