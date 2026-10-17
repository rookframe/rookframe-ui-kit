extends RefCounted

const Demo = preload("res://examples/components/pages/data_feedback/demo.gd")

static func build(page) -> void:
	var empty = page.section("Empty data and no matching results", "Each state explains why nothing is shown and supplies an appropriate next step.")
	var collection = page.scene(Demo.path("feedback/task_state"), empty, {"state": 1, "title": "No expeditions yet", "description": "Create an expedition to start planning."})
	page.button(collection.get_action_slot(), "Create expedition", func():
		collection.state = 2
		collection.title = "Expedition created"
		collection.description = "Your first expedition is ready to plan.")
	var filtered = page.scene(Demo.path("feedback/task_state"), empty, {"state": 1, "title": "No matching records", "description": "Try another phrase or clear the current filters."})
	page.button(filtered.get_action_slot(), "Clear filters", func():
		filtered.state = 2
		filtered.title = "Filters cleared")
	var states = page.section("Loading and error")
	page.scene(Demo.path("feedback/task_state"), states, {"state": 0, "title": "Loading inventory", "description": "Waiting for the latest records.", "reduced_motion": page.reduced_motion})
	var error = page.scene(Demo.path("feedback/task_state"), states, {"state": 3, "title": "Inventory unavailable", "description": "Your saved equipment has not changed."})
	page.button(error.get_action_slot(), "Try again", func():
		error.state = 2
		error.title = "Inventory restored"
		error.description = "The latest equipment is available.")
