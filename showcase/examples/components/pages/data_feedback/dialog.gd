extends RefCounted

const Demo = preload("res://examples/components/pages/data_feedback/demo.gd")

static func build(page) -> void:
	var information = page.section("Acknowledgement", "A single confirmation closes this informational dialog.")
	var status = page.note(information, "No dialog result yet.")
	var dialog = page.scene(Demo.path("overlays/dialog"), page, {"title": "Expedition briefing", "heading": "Route prepared", "description": "The northern route is ready. Your companions can review the itinerary before departure.", "confirm_label": "Got it", "show_cancel": false})
	dialog.confirmed.connect(func(): status.text = "Briefing acknowledged.")
	dialog.cancelled.connect(func(): status.text = "Briefing dismissed.")
	page.button(information, "Open acknowledgement", func(): dialog.open_dialog())
	var decision = page.section("Confirmation with body content", "Tab reaches the body and footer. Escape follows cancellation.")
	var result = page.note(decision, "No decision yet.")
	var confirm = page.scene(Demo.path("overlays/dialog"), page, {"tone": 1, "heading": "Begin the expedition?", "description": "Make sure the party has reviewed the supplies.", "confirm_label": "Begin expedition"})
	page.note(confirm.get_body_slot(), "Destination: Northern observatory\nParty: Four travellers\nExpected duration: Three days")
	confirm.confirmed.connect(func(): result.text = "Expedition confirmed in this preview.")
	confirm.cancelled.connect(func(): result.text = "Expedition cancelled.")
	page.button(decision, "Open confirmation", func(): confirm.open_dialog())
