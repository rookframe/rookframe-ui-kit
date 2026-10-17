extends RefCounted

const Demo = preload("res://examples/components/pages/layout_surfaces/demo.gd")

static func build(page) -> void:
	var display = page.section("Display card", "The surface presents information without implying activation.")
	var information = page.scene("res://rookframe/ui/components/layout/section.tscn", display, {"title": "The observatory"})
	page.note(information.get_body_slot(), "A quiet hilltop refuge overlooking the northern trade road.")
	var actions = page.section("Card with explicit action")
	var card = page.scene("res://rookframe/ui/components/layout/section.tscn", actions, {"title": "Next session", "description": "Saturday · 18:00"})
	page.note(card.get_body_slot(), "Review the notes and prepare a character before joining.")
	var status = page.note(card.get_body_slot(), "Preparation incomplete")
	page.button(card.get_action_slot(), "Mark ready", func(): status.text = "Ready for the session")
