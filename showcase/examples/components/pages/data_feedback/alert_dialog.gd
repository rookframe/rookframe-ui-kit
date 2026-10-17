extends RefCounted

const Demo = preload("res://examples/components/pages/data_feedback/demo.gd")

static func build(page) -> void:
	var danger = page.section("Destructive confirmation", "This preview updates only the status text.")
	var status = page.note(danger, "The draft is still available.")
	var dialog = page.scene("res://rookframe/ui/components/overlays/alert_dialog.tscn", page, {"tone": 2, "heading": "Discard this draft?", "description": "Unsaved route changes will be removed from this preview.", "confirm_label": "Discard draft", "cancel_label": "Keep editing"})
	dialog.confirmed.connect(func(): status.text = "Draft discarded in this preview.")
	dialog.cancelled.connect(func(): status.text = "Draft retained. Continue editing.")
	page.button(danger, "Review discard action", func(): dialog.open_dialog())
	var guarded = page.section("Confirmation requires acknowledgement")
	var gated = page.scene("res://rookframe/ui/components/overlays/alert_dialog.tscn", page, {"tone": 2, "heading": "Reset the route?", "description": "Acknowledge the consequence to enable confirmation.", "confirm_label": "Reset route", "confirm_enabled": false})
	var checkbox := preload("res://rookframe/ui/components/forms/checkbox.tscn").instantiate() as CheckBox
	checkbox.text = "I understand the route will be reset"
	checkbox.custom_minimum_size.y = 44
	gated.get_body_slot().add_child(checkbox)
	checkbox.toggled.connect(func(enabled: bool): gated.confirm_enabled = enabled)
	var result = page.note(guarded, "Reset has not been confirmed.")
	gated.confirmed.connect(func(): result.text = "Reset confirmed in this preview.")
	gated.cancelled.connect(func(): result.text = "Reset cancelled.")
	page.button(guarded, "Open guarded confirmation", func(): gated.open_dialog())
