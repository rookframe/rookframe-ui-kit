extends RefCounted

const Demo = preload("res://examples/components/pages/data_feedback/demo.gd")

static func build(page) -> void:
	var simple = page.section("Facts and supporting copy")
	var facts = page.scene(Demo.path("data/summary_block"), simple)
	var facts_data: Array[Dictionary] = [{"label": "Destination", "value": "Northern observatory"}, {"label": "Travel time", "value": "Three days"}]
	facts.configure("Journey", load("res://rookframe/ui/icons/person.svg"), facts_data, "The route follows the coast before turning into the mountains.")
	var stats = page.section("With a stat strip")
	var summary = page.scene(Demo.path("data/summary_block"), stats)
	var details_data: Array[Dictionary] = [{"label": "Role", "value": "Scout"}, {"label": "Experience", "value": "Veteran"}]
	summary.configure("Pathfinder", load("res://rookframe/ui/icons/dice.svg"), details_data, "Prepared for the next expedition.")
	var stats_data: Array[Dictionary] = [{"label": "Health", "value": "75"}, {"label": "Armor", "value": "16"}, {"label": "Speed", "value": "9"}]
	summary.set_stats(stats_data)
