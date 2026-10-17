extends RefCounted

const Demo = preload("res://examples/components/pages/data_feedback/demo.gd")

static func build(page) -> void:
	var interactive = page.section("Editable popover", "Edit the value, dismiss, and reopen to see the retained content.")
	var anchor = page.button(interactive, "Edit expedition name")
	var status = page.note(interactive, "The popover is closed.")
	var popup = page.scene(Demo.path("overlays/popover"), page, {"theme": page.preview_theme})
	page.note(popup.get_content_slot(), "Expedition name")
	var input := LineEdit.new()
	input.text = "Northern reach"
	input.accessibility_name = "Expedition name"
	input.custom_minimum_size.y = 44
	popup.get_content_slot().add_child(input)
	page.button(popup.get_content_slot(), "Done", func(): popup.close())
	anchor.pressed.connect(func(): popup.open_for(anchor, input))
	popup.closed.connect(func(reason: StringName): status.text = "Closed: %s · Name: %s" % [reason, input.text])
	var reading = page.section("Read-only content", "A second anchor demonstrates a content-only popup with Escape and outside dismissal.")
	var info_anchor = page.button(reading, "Show route information")
	var info = page.scene(Demo.path("overlays/popover"), page, {"theme": page.preview_theme})
	page.note(info.get_content_slot(), "Northern route\nThree days along the coast. The last leg crosses the observatory pass.")
	info_anchor.pressed.connect(func(): info.open_for(info_anchor))
