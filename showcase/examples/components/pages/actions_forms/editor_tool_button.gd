extends RefCounted

const Demo = preload("res://examples/components/pages/actions_forms/support.gd")

static func build(page) -> void:
	var main = page.section("Choose an editor tool", "Icon tools use explicit accessible names. Focus and selection remain distinct.")
	Demo.shell_materials(page, main)
	var group := ButtonGroup.new()
	var tools = page.flow(main)
	var status = page.note(main, "Active tool: Select")
	var buttons: Array[Button] = []
	for item in [{"title": "Select", "icon": "person"}, {"title": "Draw", "icon": "edit"}, {"title": "Layers", "icon": "layers"}]:
		var control = Demo.shell_scene(page, "res://rookframe/ui/editor/EditorToolButton.tscn", tools, {"icon": load("res://rookframe/ui/icons/" + item.icon + ".svg"), "accessibility_name": item.title, "tooltip_text": item.title, "toggle_mode": true, "button_group": group, "button_pressed": item.title == "Select"})
		buttons.append(control)
		control.toggled.connect(func(selected: bool):
			if selected: status.text = "Active tool: " + item.title
		)
	var compact := Demo.checkbox(page.flow(main), "Compact tools")
	compact.toggled.connect(func(enabled: bool):
		for control in buttons: control.set_compact(enabled)
	)
	var other = page.section("Unavailable tool", "The disabled tool retains its icon and accessible name.")
	Demo.shell_scene(page, "res://rookframe/ui/editor/EditorToolButton.tscn", page.flow(other), {"icon": load("res://rookframe/ui/icons/delete.svg"), "accessibility_name": "Delete selection", "tooltip_text": "Delete selection — no selection", "disabled": true})
	page.note(other, "Select an object before using Delete in a real editor.")
