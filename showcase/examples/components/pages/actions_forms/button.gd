extends RefCounted

const Demo = preload("res://examples/components/pages/actions_forms/support.gd")
const Action = preload("res://rookframe/ui/components/actions/button.gd")
const SCENE := "res://rookframe/ui/components/actions/button.tscn"
const VARIANTS := [
	{"name": "Primary", "variant": Action.Variant.PRIMARY, "icon": "check", "action": "Save changes"},
	{"name": "Secondary", "variant": Action.Variant.SECONDARY, "icon": "folder", "action": "Open journal"},
	{"name": "Destructive", "variant": Action.Variant.DESTRUCTIVE, "icon": "delete", "action": "Delete draft"},
]

static func build(page) -> void:
	for compact in [false, true]:
		var main = page.section("Compact" if compact else "Normal", "Primary, secondary and destructive actions. Try Tab, Enter or Space.")
		var status = page.note(main, "No command requested.")
		for item in VARIANTS:
			page.note(main, item.name)
			var row = page.flow(main)
			for content in ["text", "icon_text", "icon"]:
				var control = page.scene(SCENE, row, {
					"variant": item.variant, "compact": compact,
					"text": "" if content == "icon" else item.action,
					"icon": null if content == "text" else load("res://rookframe/ui/icons/" + item.icon + ".svg"),
					"accessibility_name": item.action, "tooltip_text": item.action if content == "icon" else "",
					"size_flags_vertical": Control.SIZE_SHRINK_CENTER,
				})
				control.pressed.connect(func(): status.text = "Confirmation requested: " + item.action if item.variant == Action.Variant.DESTRUCTIVE else "Requested: " + item.action)
	var emblem = page.section("Emblem", "A prominent icon-only action, such as the quick roll at the start of a HUD bar. The caller names it.")
	var emblem_status = page.note(emblem, "No emblem pressed.")
	var emblems = page.flow(emblem)
	for compact in [false, true]:
		for disabled in [false, true]:
			var control = page.scene(SCENE, emblems, {"variant": Action.Variant.EMBLEM, "compact": compact, "disabled": disabled, "icon": load("res://rookframe/ui/icons/dice.svg"), "accessibility_name": "Roll dice", "tooltip_text": "Roll dice", "size_flags_vertical": Control.SIZE_SHRINK_CENTER})
			control.pressed.connect(func(): emblem_status.text = "Requested: Roll dice")
	var unavailable = page.section("Disabled", "Unavailable actions retain their labels and icons.")
	for compact in [false, true]:
		var row = page.flow(unavailable)
		for item in VARIANTS:
			for icon_only in [false, true]:
				page.scene(SCENE, row, {"variant": item.variant, "compact": compact, "text": "" if icon_only else item.name, "icon": load("res://rookframe/ui/icons/" + item.icon + ".svg"), "disabled": true, "accessibility_name": item.action, "tooltip_text": item.action, "size_flags_vertical": Control.SIZE_SHRINK_CENTER})
	var retained = page.section("Selection and live sizing", "Changing variant or size keeps the same native toggle and keyboard focus.")
	var toggle = page.scene(SCENE, page.flow(retained), {"text": "Keep selected", "icon": load("res://rookframe/ui/icons/check.svg"), "toggle_mode": true})
	var options = page.flow(retained)
	Demo.checkbox(options, "Compact size").toggled.connect(toggle.set_compact)
	Demo.checkbox(options, "Primary action").toggled.connect(func(enabled: bool): toggle.variant = Action.Variant.PRIMARY if enabled else Action.Variant.SECONDARY)
	Demo.checkbox(options, "Disable action").toggled.connect(func(enabled: bool): toggle.disabled = enabled)
	var copy = page.section("Long and translated labels", "Native Button sizing keeps the complete label readable; action groups wrap.")
	var labels = page.flow(copy)
	for title in ["Save all changes to the current draft", "Сохранить изменения", "Änderungen speichern"]:
		page.scene(SCENE, labels, {"text": title, "variant": Action.Variant.PRIMARY})
