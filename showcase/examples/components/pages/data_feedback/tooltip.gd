extends RefCounted

const Demo = preload("res://examples/components/pages/data_feedback/demo.gd")

static func build(page) -> void:
	var simple = page.section("Text hint")
	var button = page.button(simple, "Inspect route")
	button.set_script(preload("res://examples/components/pages/data_feedback/tooltip_source.gd"))
	button.tooltip_text = "View the destination, travel time, and supplies."
	button.accessibility_description = button.tooltip_text
	var details = page.note(simple, "Activate Inspect route to see its details.")
	button.pressed.connect(func(): details.text = "Destination: Northern observatory · Travel time: Three days · Supplies: Ready")
	var icon = page.section("Icon action", "The tooltip supplements an explicit accessible action name.")
	var icon_button = page.button(icon, "")
	icon_button.set_script(preload("res://examples/components/pages/data_feedback/tooltip_source.gd"))
	icon_button.icon = load("res://rookframe/ui/icons/dice.svg")
	icon_button.accessibility_name = "Roll expedition check"
	icon_button.tooltip_text = "Roll an expedition check"
	var result = page.note(icon, "No roll yet.")
	icon_button.pressed.connect(func(): result.text = "Expedition check: 18")
