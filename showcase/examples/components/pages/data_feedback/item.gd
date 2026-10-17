extends RefCounted

const Demo = preload("res://examples/components/pages/data_feedback/demo.gd")

static func build(page) -> void:
	var display = page.section("Display item", "A read-only record with an explicit action.")
	var record = page.scene(Demo.path("data/structured_row"), display, {"title": "Moonstone compass", "detail": "Explorer equipment", "value_text": "1 kg"})
	var status = page.note(display, "No action requested.")
	page.button(record.get_action_slot(), "Inspect compass", func(): status.text = "Compass inspection requested.")
	var selection = page.section("Selectable item", "The entire choice row is one native toggle target.")
	var choice = page.scene(Demo.path("forms/choice_row"), selection, {"title": "Field journal", "description": "Include in the expedition supplies"})
	var selected = page.note(selection, "Journal is not selected.")
	choice.selection_changed.connect(func(value: bool): selected.text = "Journal selected." if value else "Journal is not selected.")
	var activation = page.section("Action item", "Activation requests an action without becoming a selection.")
	var action = page.scene(Demo.path("data/action_row"), activation, {"title": "Review expedition", "description": "Open the itinerary and supplies"})
	var result = page.note(activation, "Review has not been requested.")
	action.pressed.connect(func(): result.text = "Review requested.")
