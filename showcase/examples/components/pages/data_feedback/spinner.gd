extends RefCounted

const Demo = preload("res://examples/components/pages/data_feedback/demo.gd")

static func build(page) -> void:
	var loading = page.section("Indeterminate loading", "The message explains what is happening when the total is unknown.")
	var state = page.scene("res://rookframe/ui/components/feedback/spinner.tscn", loading, {"state": 0, "title": "Loading expedition records", "description": "Waiting for the latest records from the world.", "reduced_motion": page.reduced_motion})
	var controls = page.flow(loading)
	page.button(controls, "Complete loading", func():
		state.state = 2
		state.title = "Records are ready")
	page.button(controls, "Restart loading", func():
		state.state = 0
		state.title = "Loading expedition records")
	var reduced = page.section("Reduced motion", "The same labelled loading state uses a static indicator and leaves focus unchanged.")
	var static_state = page.scene("res://rookframe/ui/components/feedback/spinner.tscn", reduced, {"state": 0, "title": "Preparing a preview", "description": "This example always uses reduced motion.", "reduced_motion": true})
	static_state.set_meta("fixed_reduced_motion", true)
