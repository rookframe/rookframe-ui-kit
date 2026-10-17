extends SceneTree
## Native shell recipes must remain usable without optional Theme mappings.
var failures: Array[String] = []

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	for path in ["menu/MenuButtonPrimary.tscn", "menu/MenuChoice.tscn", "editor/EditorToolButton.tscn", "menu/Switch.tscn"]:
		var control: Control = load("res://rookframe/ui/" + path).instantiate()
		root.add_child(control)
		await process_frame
		check(control.get_combined_minimum_size().y >= 44, path + " retains a 44px native target")
		if path == "menu/Switch.tscn":
			var title: Label = control.get_node("Content/Row/Copy/Title")
			check(title.get_theme_color("font_color") == control.get_theme_color("font_color", "Button"), "Card copy uses native Button text color")
			check(not title.has_theme_color_override("font_shadow_color"), "Native card copy does not acquire an optional ink shadow")
			control.disabled = true
			control._update_state()
			check(title.get_theme_color("font_color") == control.get_theme_color("font_disabled_color", "Button"), "Disabled card copy uses native disabled text color")
			var mark: TextureRect = control.get_node("Content/Row/SelectionMark")
			check(mark.texture == control.get_theme_icon("checked", "CheckBox"), "Card selection uses a native checkmark")
		control.free()
	for failure in failures:
		push_error(failure)
	print("NATIVE_RECIPE_DEFAULTS: %d failures" % failures.size())
	quit(0 if failures.is_empty() else 1)

func check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
