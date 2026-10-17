extends RefCounted

const Demo = preload("res://examples/components/pages/data_feedback/demo.gd")

static func build(page) -> void:
	for with_action in [false, true]:
		var section = page.section("Read-only inspection" if not with_action else "Inspection with an action", "Hover for a preview, or activate Inspect for the full details.")
		var anchor = page.button(section, "Inspect field journal" if not with_action else "Inspect moonstone compass")
		var status = page.note(section, "No action requested.")
		var card = page.scene(Demo.path("overlays/inspect_card"), page, {"theme": page.preview_theme})
		var title: String = "Field journal" if not with_action else "Moonstone compass"
		page.note(card.get_preview_slot(), title + "\nExplorer equipment. Activate Inspect for details.")
		page.note(card.get_body_slot(), title + "\nA reliable travelling companion for the northern expedition. Weight: 1 kg.")
		if with_action:
			page.button(card.get_action_slot(), "Equip compass", func():
				status.text = "Compass equipped in this preview."
				card.close())
		else:
			page.button(card.get_action_slot(), "Close inspection", func(): card.close())
		card.bind_anchor(anchor)
		anchor.pressed.connect(func(): card.open_inspection())
