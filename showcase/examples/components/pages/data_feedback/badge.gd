extends RefCounted

const Demo = preload("res://examples/components/pages/data_feedback/demo.gd")

static func build(page) -> void:
	var simple = page.section("Text labels", "Status is communicated in words as well as appearance.")
	var row = page.flow(simple)
	for copy in ["Ready", "In review", "Unavailable"]:
		page.scene(Demo.path("data/badge"), row, {"label_text": copy})
	var icons = page.section("Icon and longer label", "Badges remain read-only and do not add focus targets.")
	page.scene(Demo.path("data/badge"), icons, {"label_text": "Shared with the entire expedition", "icon": load("res://rookframe/ui/icons/person.svg")})
	page.scene(Demo.path("data/badge"), icons, {"label_text": "Roll recorded", "icon": load("res://rookframe/ui/icons/dice.svg")})
