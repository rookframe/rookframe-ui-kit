extends RefCounted

const Demo = preload("res://examples/components/pages/data_feedback/demo.gd")

static func build(page) -> void:
	var states = page.section("Sequence states", "Results remain empty until a roll is available.")
	for index in 4:
		page.scene(Demo.path("data/roll_row"), states, {"state": index, "ordinal": str(index + 1), "title": ["Strength", "Agility", "Insight", "Resolve"][index], "detail": ["Recorded result", "Ready to roll", "Waiting for Agility", "Requires the next chapter"][index], "result": "17" if index == 0 else ""})
	var interactive = page.section("Record a result")
	var roll = page.scene(Demo.path("data/roll_row"), interactive, {"state": 1, "ordinal": "1", "title": "Expedition check", "detail": "Synthetic result for this preview"})
	var action = page.button(roll.get_action_slot(), "Roll")
	action.pressed.connect(func():
		roll.state = 0
		roll.result = "18"
		action.disabled = true)
	page.button(interactive, "Reset roll", func():
		roll.state = 1
		roll.result = ""
		action.disabled = false)
