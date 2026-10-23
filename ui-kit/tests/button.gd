extends SceneTree
## Shared Button preserves native interaction across semantic and density changes.
const Scene = preload("res://rookframe/ui/components/actions/button.tscn")
const Action = preload("res://rookframe/ui/components/actions/button.gd")
const Icon = preload("res://rookframe/ui/icons/check.svg")
var failures: Array[String] = []
var assertions := 0
var host: HFlowContainer

func _initialize() -> void:
	_run.call_deferred()

func check(condition: bool, message: String) -> void:
	assertions += 1
	if not condition:
		failures.append(message)

func press(control: Button) -> void:
	control.grab_focus()
	await process_frame
	for down in [true, false]:
		var event := InputEventAction.new()
		event.action = &"ui_accept"
		event.pressed = down
		root.push_input(event)
		await process_frame

func _run() -> void:
	root.size = Vector2i(1024, 768)
	host = HFlowContainer.new()
	root.add_child(host)
	host.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for variant in [Action.Variant.PRIMARY, Action.Variant.SECONDARY, Action.Variant.DESTRUCTIVE, Action.Variant.EMBLEM]:
		for compact in [false, true]:
			for content in ["text", "icon_text", "icon"]:
				var control = Scene.instantiate()
				control.variant = variant
				control.compact = compact
				control.text = "" if content == "icon" else "Apply"
				control.icon = null if content == "text" else Icon
				control.accessibility_name = "Apply changes"
				control.tooltip_text = "Apply changes"
				host.add_child(control)
				await process_frame
				var height := 44 if compact else 52
				check(control.get_combined_minimum_size().y == height, "Native density target for %s/%s/%s" % [variant, compact, content])
				check(control.theme_type_variation == StringName(String(Action.THEME_TYPES[variant]) + ("__compact" if compact else "")), "Variant resolves its semantic Theme type")
				if content == "icon":
					check(control.get_combined_minimum_size() == Vector2(height, height), "Icon-only target is square")
					check(control.icon_alignment == HORIZONTAL_ALIGNMENT_CENTER, "Icon-only image is centered")
				var events := []
				control.pressed.connect(func(): events.append(true))
				await press(control)
				check(events.size() == 1, "Native keyboard emits once for every variant and content")
				control.disabled = true
				await press(control)
				check(events.size() == 1, "Disabled variant cannot activate")
				check(control.theme == null and not control.has_theme_stylebox_override("normal"), "Core supplies no appearance")
				check(control.text == ("" if content == "icon" else "Apply") and control.icon == (null if content == "text" else Icon), "Presentation preserves caller content")
				control.free()
	await _live_changes()
	for failure in failures: push_error(failure)
	print("BUTTON: %d assertions; %d failures" % [assertions, failures.size()])
	quit(0 if failures.is_empty() else 1)

func _live_changes() -> void:
	var control = Scene.instantiate()
	control.text = "Selected"
	control.icon = Icon
	control.toggle_mode = true
	host.add_child(control)
	await press(control)
	var identity: int = control.get_instance_id()
	var theme := Theme.new()
	for type in Action.THEME_TYPES:
		theme.set_type_variation(type, &"Button")
		theme.set_type_variation(StringName(String(type) + "__compact"), type)
	theme.set_color("font_color", &"components_button_primary", Color.RED)
	theme.set_color("icon_normal_color", &"components_button_primary", Color.RED)
	theme.set_constant("minimum_height", &"components_button_primary", 72)
	theme.set_constant("minimum_height", &"components_button_primary__compact", 48)
	host.theme = theme
	control.variant = Action.Variant.PRIMARY
	check(control.get_theme_color("font_color") == Color.RED and control.get_theme_color("icon_normal_color") == Color.RED, "Variant resolves consumer text and icon appearance")
	check(control.custom_minimum_size.y == 72, "Theme minimum target is inherited")
	control.compact = true
	check(control.custom_minimum_size.y == 48, "Compact theme minimum replaces normal minimum")
	check(control.get_theme_color("font_color") == Color.RED, "Compact inherits the normal variant")
	theme.set_constant("minimum_height", &"components_button_primary__compact", 60)
	await process_frame
	check(control.custom_minimum_size.y == 60, "Live theme edits update target size")
	host.theme = null
	await process_frame
	check(control.custom_minimum_size.y == 44, "Removing the theme restores compact native target")
	control.compact = false
	check(control.custom_minimum_size.y == 52, "Normal density restores its native target")
	check(control.get_instance_id() == identity and control.button_pressed and control.has_focus(), "Theme, density and variant changes retain identity, selection and focus")
	control.icon_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	control.text = ""
	await process_frame
	check(control.icon_alignment == HORIZONTAL_ALIGNMENT_CENTER, "Live icon-only configuration centers its icon")
	control.text = "Selected"
	await process_frame
	check(control.icon_alignment == HORIZONTAL_ALIGNMENT_RIGHT, "Restoring a label retains caller icon alignment")
	control.custom_minimum_size = Vector2(300, 80)
	control.compact = true
	control.variant = Action.Variant.DESTRUCTIVE
	host.theme = theme
	await process_frame
	check(control.custom_minimum_size == Vector2(300, 80), "Repeated changes preserve caller minimum dimensions")
	control.text = "Save all changes to the current draft — Änderungen speichern"
	check(control.get_minimum_size().x > 300, "Native text measurement grows for long labels")
	var packed := PackedScene.new()
	check(packed.pack(control) == OK, "Variant scene can be saved")
	var restored = packed.instantiate()
	check(restored.variant == Action.Variant.DESTRUCTIVE and restored.compact and restored.icon == Icon, "Serialized configuration retains variant, density and icon")
	restored.free()
	control.free()
