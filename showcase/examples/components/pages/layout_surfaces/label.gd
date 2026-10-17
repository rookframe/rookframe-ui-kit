extends RefCounted

const Demo = preload("res://examples/components/pages/layout_surfaces/demo.gd")

static func build(page) -> void:
	var display = page.section("Display labels", "Labels communicate information without entering the focus order.")
	page.note(display, "Campaign name")
	page.note(display, "Beyond the horizon")
	var form = page.section("Input relationship", "The visible label and native accessible name describe the same input.")
	page.note(form, "Character name")
	Demo.editor(form, "Mira", "Character name")
	page.note(form, "Use a name that the other players will recognize.")
	var required = page.section("Required field")
	var field = page.scene("res://rookframe/ui/components/forms/field.tscn", required, {"label_text": "Expedition title (required)", "help_text": "Give this expedition a clear name."})
	var input := Demo.editor(field.get_input_slot(), "Northern expedition", "Expedition title")
	field.set_target(input)
