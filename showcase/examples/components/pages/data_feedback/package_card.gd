extends RefCounted

const Demo = preload("res://examples/components/pages/data_feedback/demo.gd")

static func build(page) -> void:
	var available = page.section("Available and selected")
	page.scene(Demo.path("data/package_card"), available, {"package_name": "Northern expedition", "detail_text": "Adventure content · Version 1.4"})
	page.scene(Demo.path("data/package_card"), available, {"package_name": "Cartographer tools", "detail_text": "Optional maps and travel aids", "selected": true})
	var required = page.section("Required package", "The host supplies package availability; this record has no selection action.")
	page.scene(Demo.path("data/package_card"), required, {"package_name": "Expedition core", "detail_text": "Required rules for this world", "selected": true, "locked": true, "locked_state_label": "Required"})
