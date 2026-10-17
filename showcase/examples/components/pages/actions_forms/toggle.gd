extends RefCounted

const Demo = preload("res://examples/components/pages/actions_forms/support.gd")

static func build(page) -> void:
	var main = page.section("Persistent mode", "Pressed state communicates a mode independently of keyboard focus.")
	var toggle = page.scene("res://rookframe/ui/components/actions/toggle.tscn", page.flow(main), {"text": "Show annotations"})
	toggle.toggle_mode = true
	var status = page.note(main, "Annotations hidden.")
	toggle.toggled.connect(func(selected: bool): status.text = "Annotations visible." if selected else "Annotations hidden.")
	page.button(page.flow(main), "Focus toggle", toggle.grab_focus)
	var states = page.section("Pressed and disabled", "Availability can change while the selected mode is retained.")
	var locked = page.scene("res://rookframe/ui/components/actions/toggle.tscn", page.flow(states), {"text": "Snap to grid"})
	locked.toggle_mode = true
	locked.button_pressed = true
	locked.disabled = true
	var unlock := Demo.checkbox(page.flow(states), "Allow changing snap")
	unlock.toggled.connect(func(enabled: bool): locked.disabled = not enabled)
	var feedback = page.note(states, "Snap to grid enabled.")
	locked.toggled.connect(func(selected: bool): feedback.text = "Snap to grid enabled." if selected else "Snap to grid disabled.")
