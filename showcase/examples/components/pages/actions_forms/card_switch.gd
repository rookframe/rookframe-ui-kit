extends RefCounted

const Demo = preload("res://examples/components/pages/actions_forms/support.gd")

static func build(page) -> void:
	var main = page.section("Independent card", "A card explains a choice and keeps its selection marker in a stable position.")
	Demo.shell_materials(page, main)
	var card = Demo.shell_scene(page, "res://rookframe/ui/menu/Switch.tscn", main, {"title": "Guided exploration", "description": "Show helpful context when entering a location for the first time."})
	var status = page.note(main, "Guided exploration is off.")
	card.toggled.connect(func(enabled: bool): status.text = "Guided exploration is on." if enabled else "Guided exploration is off.")
	var compact := Demo.checkbox(page.flow(main), "Compact density")
	compact.toggled.connect(card.set_compact)
	var states = page.section("Disabled choices", "Availability and selection are separate: locked cards may be selected or unselected.")
	Demo.shell_scene(page, "res://rookframe/ui/menu/Switch.tscn", states, {"title": "Campaign guidance", "description": "Enabled by the campaign owner.", "button_pressed": true, "disabled": true, "compact": true})
	Demo.shell_scene(page, "res://rookframe/ui/menu/Switch.tscn", states, {"title": "Live hints", "description": "Unavailable while offline.", "disabled": true, "compact": true})
