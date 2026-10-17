extends RefCounted

const Demo = preload("res://examples/components/pages/actions_forms/support.gd")

static func build(page) -> void:
	var main = page.section("Choose one mode", "Cards share the available width and stack together on narrow views.")
	var tray = Demo.shell_scene(page, "res://rookframe/ui/menu/SwitchGroup.tscn", main)
	var group := ButtonGroup.new()
	var status = page.note(main, "Selected: Guided")
	for title in ["Guided", "Freeform"]:
		var card = Demo.shell_scene(page, "res://rookframe/ui/menu/Switch.tscn", tray.get_options(), {"title": title, "description": "Follow a suggested path." if title == "Guided" else "Set your own direction.", "button_group": group, "button_pressed": title == "Guided"})
		card.toggled.connect(func(selected: bool):
			if selected: status.text = "Selected: " + title
		)
	var compact := Demo.checkbox(page.flow(main), "Compact density")
	compact.toggled.connect(tray.set_compact)
	var independent = page.section("Choose several resources", "These compact cards are independent, so several can remain included.")
	var other = Demo.shell_scene(page, "res://rookframe/ui/menu/SwitchGroup.tscn", independent, {"compact": true})
	var feedback = page.note(independent, "Choose any resources.")
	for title in ["Maps", "Journals", "Portraits"]:
		var card = Demo.shell_scene(page, "res://rookframe/ui/menu/Switch.tscn", other.get_options(), {"title": title, "description": "Include " + title.to_lower() + " in the archive.", "compact": true})
		card.toggled.connect(func(selected: bool): feedback.text = title + (" included." if selected else " excluded."))
