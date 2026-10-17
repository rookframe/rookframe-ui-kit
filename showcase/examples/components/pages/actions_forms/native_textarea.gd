extends RefCounted

const Demo = preload("res://examples/components/pages/actions_forms/support.gd")

static func build(page) -> void:
	var main = page.section("Multiline draft", "Text wraps inside the editor. Leaving focus commits the local draft.")
	page.note(main, "Session notes")
	var editor := Demo.text(main, "Session notes", "We arrived before sunset.\nThe archive was still open.")
	var status = page.note(main, "Edit the session notes.")
	editor.text_changed.connect(func(): status.text = "%d characters in draft." % editor.text.length())
	editor.focus_exited.connect(func(): status.text = "Committed %d characters locally." % editor.text.length())
	page.button(page.flow(main), "Focus editor", editor.grab_focus)
	var other = page.section("Read-only transcript", "Select and copy retained text while editing is locked.")
	page.note(other, "Archived transcript")
	var locked := Demo.text(other, "Archived transcript", "The archivist welcomed the travellers and opened the harbour ledger.\nEach entry recorded a ship, its captain and the date of arrival.")
	locked.editable = false
	var unlock := Demo.checkbox(page.flow(other), "Allow editing")
	unlock.toggled.connect(func(enabled: bool): locked.editable = enabled)
