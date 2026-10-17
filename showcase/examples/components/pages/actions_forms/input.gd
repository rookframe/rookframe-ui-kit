extends RefCounted

const Demo = preload("res://examples/components/pages/actions_forms/support.gd")

static func build(page) -> void:
	var main = page.section("Single-line input", "Type freely; Enter commits the current value.")
	page.note(main, "Character name")
	var input := Demo.line(main, "Character name")
	input.placeholder_text = "e.g. Elara"
	var status = page.note(main, "No value submitted.")
	input.text_changed.connect(func(value: String): status.text = "%d characters in draft." % value.length())
	input.text_submitted.connect(func(value: String): status.text = "Submitted: " + value)
	page.button(page.flow(main), "Focus input", input.grab_focus)
	var other = page.section("Read-only and secret input", "Read-only text still supports native selection and copy. A secret input masks entered characters.")
	page.note(other, "Record identifier")
	var locked := Demo.line(other, "Record identifier", "CHAR-0142")
	locked.editable = false
	page.note(other, "Preview passphrase")
	var secret := Demo.line(other, "Preview passphrase")
	secret.secret = true
	secret.placeholder_text = "Local demo only"
	var reveal := Demo.checkbox(page.flow(other), "Show passphrase")
	reveal.toggled.connect(func(enabled: bool): secret.secret = not enabled)
