extends RefCounted

const Demo = preload("res://examples/components/pages/actions_forms/support.gd")

static func build(page) -> void:
	var main = page.section("Text and icon actions", "Use Tab to inspect keyboard focus, then Enter or Space to activate.")
	var actions = page.flow(main)
	var status = page.note(main, "No command requested.")
	page.button(actions, "Save changes", func(): status.text = "Changes saved locally.")
	var icon = page.button(actions, "Open journal", func(): status.text = "Journal requested.")
	icon.icon = load("res://rookframe/ui/icons/folder.svg")
	icon.expand_icon = true
	icon.add_theme_constant_override("icon_max_width", 24)
	var only_icon = page.button(actions, "", func(): status.text = "Refresh requested.")
	only_icon.icon = load("res://rookframe/ui/icons/restore.svg")
	only_icon.accessibility_name = "Refresh records"
	only_icon.tooltip_text = "Refresh records"
	only_icon.expand_icon = true
	only_icon.add_theme_constant_override("icon_max_width", 24)
	var other = page.section("Disabled action", "The same action can become available without replacing its native control.")
	var action = page.button(page.flow(other), "Publish draft")
	action.disabled = true
	var ready := Demo.checkbox(page.flow(other), "Draft is ready")
	ready.toggled.connect(func(enabled: bool): action.disabled = not enabled)
	var result = page.note(other, "Draft not ready.")
	action.pressed.connect(func(): result.text = "Publish requested locally.")
