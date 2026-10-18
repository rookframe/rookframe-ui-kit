extends RefCounted

const Demo = preload("res://examples/components/pages/actions_forms/support.gd")

static func build(page) -> void:
	var main = page.section("Independent choices", "Each checkbox changes only its own value.")
	var status = page.note(main, "Choose what to include.")
	for title in ["Include session notes", "Include discovered locations"]:
		var check := Demo.checkbox(main, title, title == "Include session notes")
		check.toggled.connect(func(enabled: bool): status.text = title + (": included" if enabled else ": excluded"))
	var states = page.section("Disabled states", "A locked boolean keeps its current value and cannot be changed by activation.")
	var selected := Demo.checkbox(states, "Core rules are required", true)
	selected.disabled = true
	var unselected := Demo.checkbox(states, "Shared export is unavailable")
	unselected.disabled = true
	page.note(states, "This recipe has checked and unchecked states; it does not imply a mixed state.")
	var content = page.section("Long labels and direction", "The entire label is one target. Tab to a choice and press Space to toggle it.")
	Demo.checkbox(content, "Include discovered locations and handwritten notes", true)
	Demo.checkbox(content, "Сохранить заметки · Notizen speichern")
	var rtl := Demo.checkbox(content, "Include session notes — RTL", true)
	rtl.layout_direction = Control.LAYOUT_DIRECTION_RTL
