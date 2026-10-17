extends RefCounted

static func build(page) -> void:
	var main = page.section("Task footer", "Leading and trailing commands retain source order when the action bar stacks.")
	var bar = page.scene("res://rookframe/ui/components/layout/action_bar.tscn", main)
	var status = page.note(main, "Draft unchanged.")
	page.button(bar.get_leading_slot(), "Back", func(): status.text = "Back requested.")
	var trailing = bar.get_trailing_slot()
	page.button(trailing, "Save draft", func(): status.text = "Draft saved locally.")
	page.button(trailing, "Continue", func(): status.text = "Continue requested.")
	var other = page.section("Wrapping command group", "Related commands remain separate actions. They wrap together at constrained widths.")
	var commands = page.scene("res://rookframe/ui/components/actions/button_group.tscn", other)
	var result = page.note(other, "Choose an editing command.")
	for title in ["Duplicate", "Archive", "Restore"]:
		page.button(commands, title, func(): result.text = title + " requested.")
	var disabled = page.button(commands, "Delete")
	disabled.disabled = true
