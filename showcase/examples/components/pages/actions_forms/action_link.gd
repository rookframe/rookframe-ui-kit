extends RefCounted

static func build(page) -> void:
	var main = page.section("Quiet navigation", "The label, rule and arrow form one native target.")
	var status = page.note(main, "Choose a destination.")
	for title in ["View journals", "Manage packages"]:
		var link = page.scene("res://rookframe/ui/components/data/action_link.tscn", main, {"title": title, "title_lane_width": 190.0})
		link.pressed.connect(func(): status.text = "Destination requested: " + title)
	var other = page.section("Long label and availability", "The title lane can be adjusted for the copy while the action keeps its native focus and disabled states.")
	var long_link = page.scene("res://rookframe/ui/components/data/action_link.tscn", other, {"title": "Browse campaign history", "title_lane_width": 240.0})
	var result = page.note(other, "Campaign history is available.")
	long_link.pressed.connect(func(): result.text = "Campaign history requested.")
	page.scene("res://rookframe/ui/components/data/action_link.tscn", other, {"title": "Shared archive", "disabled": true})
