extends RefCounted

const Demo = preload("res://examples/components/pages/layout_surfaces/demo.gd")

static func build(page) -> void:
	var simple = page.section("Read-only section")
	Demo.panel(page, simple, "Session overview", "The party reached the observatory just before nightfall.")
	var editable = page.section("Section with an action", "The body and action keep native input and focus order.")
	var frame = Demo.skin(page, "components/layout/section.tscn", editable, {"title": "Campaign details", "description": "Give this campaign a name that everyone at the table will recognize."})
	var name_field = Demo.editor(frame.get_body_slot(), "Beyond the horizon", "Campaign name")
	var status = page.note(frame.get_body_slot(), "Unsaved example")
	page.button(frame.get_action_slot(), "Save", func(): status.text = "Saved: " + name_field.text)
