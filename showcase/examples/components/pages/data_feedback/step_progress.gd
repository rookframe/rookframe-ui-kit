extends RefCounted

const Demo = preload("res://examples/components/pages/data_feedback/demo.gd")

static func build(page) -> void:
	var interactive = page.section("Three-step workflow", "Previous and Next update the example; the progress rail itself is read-only.")
	var progress = page.scene(Demo.path("feedback/step_progress"), interactive, {"steps": PackedStringArray(["Choose a route", "Prepare supplies", "Review expedition"]), "current_step": 2})
	var actions = page.flow(interactive)
	page.button(actions, "Previous step", func(): progress.current_step = maxi(1, progress.current_step - 1))
	page.button(actions, "Next step", func(): progress.current_step = mini(3, progress.current_step + 1))
	var long_copy = page.section("Long labels and final step")
	page.scene(Demo.path("feedback/step_progress"), long_copy, {"steps": PackedStringArray(["Confirm the expedition destination", "Invite your travelling companions", "Review the supplies and departure time", "Begin the journey"]), "current_step": 4})
