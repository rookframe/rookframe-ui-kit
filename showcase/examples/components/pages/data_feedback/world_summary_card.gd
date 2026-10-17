extends RefCounted

const Demo = preload("res://examples/components/pages/data_feedback/demo.gd")

static func build(page) -> void:
	var read_only = page.section("Read-only summary")
	page.scene(Demo.path("data/world_summary_card"), read_only, {"facts_visible": false, "actions_visible": false, "kicker_text": "NORTHERN REACH", "privacy_text": "PRIVATE", "package_name": "Northern expedition", "detail_text": "Core rules and local content · Version 1.4"})
	var actions = page.section("With explicit actions")
	var card = page.scene(Demo.path("data/world_summary_card"), actions, {"facts_visible": false, "actions_visible": true, "kicker_text": "GLASS DESERT", "privacy_text": "SHARED", "package_name": "Desert expedition", "detail_text": "Available to all members of this world"})
	var status = page.note(actions, "Choose a world action.")
	# OpenWorld and WorldDetails are the documented public native action nodes.
	card.find_child("OpenWorld").pressed.connect(func(): status.text = "Open world requested.")
	card.find_child("WorldDetails").pressed.connect(func(): status.text = "World details requested.")
