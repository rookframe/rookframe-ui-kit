extends RefCounted

const Demo = preload("res://examples/components/pages/actions_forms/support.gd")

static func build(page) -> void:
	var main = page.section("Navigate or manage", "The full row activates one local action; title and detail stay visible.")
	var row = page.scene("res://rookframe/ui/components/data/disclosure_row.tscn", main, {"title": "Campaign settings", "description": "Manage the region, journal and shared resources.", "action_label": "Open"})
	var status = page.note(main, "No action requested.")
	row.pressed.connect(func(): status.text = "Campaign settings requested.")
	var controls = page.flow(main)
	page.button(controls, "Focus row", row.grab_focus)
	var disable := Demo.checkbox(controls, "Disable row")
	disable.toggled.connect(func(enabled: bool): row.disabled = enabled)
	var states = page.section("Destructive and unavailable", "Danger communicates the consequence. This preview records intent without deleting anything.")
	var danger = page.scene("res://rookframe/ui/components/data/disclosure_row.tscn", states, {"title": "Remove archive", "description": "A real host asks for confirmation before removing retained entries.", "action_label": "Review", "tone": 1})
	var result = page.note(states, "Archive retained.")
	danger.pressed.connect(func(): result.text = "Removal confirmation requested; archive retained.")
	page.scene("res://rookframe/ui/components/data/disclosure_row.tscn", states, {"title": "Transfer ownership", "description": "Only the current owner can transfer this campaign.", "disabled": true})
