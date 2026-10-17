extends RefCounted

const Demo = preload("res://examples/components/pages/actions_forms/support.gd")

static func build(page) -> void:
	var main = page.section("Label, help and validation", "Field associates its label and supporting copy with a native input.")
	var field = page.scene("res://rookframe/ui/components/forms/field.tscn", main, {"label_text": "Display name", "help_text": "Use at least three characters."})
	var input := Demo.line(field.get_input_slot(), "Display name", "Elara")
	field.set_target(input)
	var status = page.note(main, "Ready to validate.")
	input.text_submitted.connect(func(value: String):
		field.set_error("Use at least three characters." if value.strip_edges().length() < 3 else "")
		status.text = "Name accepted." if field.error_text.is_empty() else "Name needs attention."
	)
	var controls = page.flow(main)
	page.button(controls, "Focus input", field.focus_input)
	page.button(controls, "Show error", func(): field.set_error("That display name is already taken."))
	page.button(controls, "Clear error", func(): field.set_error(""))
	var other = page.section("Choice group", "The field names the group; each native choice keeps its own name.")
	var grouped = page.scene("res://rookframe/ui/components/forms/field.tscn", other, {"label_text": "Notification channels", "help_text": "Select any channels you want to receive."})
	var choices := VBoxContainer.new()
	grouped.get_input_slot().add_child(choices)
	grouped.set_target(choices)
	var status_group = page.note(other, "No changes yet.")
	for title in ["Session reminders", "Journal updates"]:
		var choice := Demo.checkbox(choices, title)
		choice.toggled.connect(func(enabled: bool): status_group.text = title + (" enabled." if enabled else " disabled."))
	var hide := Demo.checkbox(page.flow(other), "Hide visible group label")
	hide.toggled.connect(func(enabled: bool): grouped.label_visible = not enabled)
