extends RefCounted

const Demo = preload("res://examples/components/pages/actions_forms/support.gd")

static func build(page) -> void:
	var main = page.section("Primary and standard", "Related commands keep independent behavior and native source order.")
	var actions = page.flow(main)
	var status = page.note(main, "No editor action requested.")
	var save = Demo.shell_scene(page, "res://rookframe/ui/editor/EditorActionButton.tscn", actions, {"text": "Save scene", "icon": load("res://rookframe/ui/icons/check.svg")})
	var preview = Demo.shell_scene(page, "res://rookframe/ui/editor/EditorActionButton.tscn", actions, {"text": "Preview", "usage": "editor.button.standard"})
	save.pressed.connect(func(): status.text = "Scene saved in this preview.")
	preview.pressed.connect(func(): status.text = "Preview requested.")
	var compact := Demo.checkbox(page.flow(main), "Compact density")
	compact.toggled.connect(func(enabled: bool): save.set_compact(enabled); preview.set_compact(enabled))
	var other = page.section("Disabled action", "Availability changes without replacing the action.")
	var export_action = Demo.shell_scene(page, "res://rookframe/ui/editor/EditorActionButton.tscn", page.flow(other), {"text": "Export scene", "disabled": true})
	var allow := Demo.checkbox(page.flow(other), "Allow export")
	allow.toggled.connect(func(enabled: bool): export_action.disabled = not enabled)
	var result = page.note(other, "Export is unavailable.")
	export_action.pressed.connect(func(): result.text = "Export requested locally.")
