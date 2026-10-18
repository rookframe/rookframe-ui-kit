extends SceneTree
## Optional menu appearance must preserve the shared Button's native contract.
const Scene = preload("res://rookframe/ui/components/actions/button.tscn")
const Fantasy = preload("res://rookframe/ui/themes/fantasy/theme.tres")
const Icon = preload("res://rookframe/ui/icons/check.svg")
const CarvedStyle = preload("res://rookframe/ui/themes/fantasy/button_style.gd")
var failures: Array[String] = []
var assertions := 0
var host: Control
var capture_dir := ""

func _initialize() -> void:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--capture-dir="):
			capture_dir = argument.trim_prefix("--capture-dir=")
	if not capture_dir.is_empty():
		DirAccess.make_dir_recursive_absolute(capture_dir)
	_run.call_deferred()

func check(condition: bool, message: String) -> void:
	assertions += 1
	if not condition:
		failures.append(message)
		push_error(message)

func settle() -> void:
	for frame in 6: await process_frame

func _run() -> void:
	root.size = Vector2i(1024, 768)
	host = Control.new()
	host.theme = Fantasy
	root.add_child(host)
	for variant in 3:
		for compact in [false, true]:
			for content in ["text", "icon_text", "icon"]:
				var control = Scene.instantiate()
				control.variant = variant
				control.compact = compact
				control.text = "" if content == "icon" else "Apply changes"
				control.icon = null if content == "text" else Icon
				control.accessibility_name = "Apply changes"
				host.add_child(control)
				await settle()
				var face = control.get_theme_stylebox("normal")
				check(face is CarvedStyle, "All variants, densities and content receive carved caps")
				check(face.surface.texture == control.get_theme_icon("cap"), "Semantic role selects its original cap")
				if variant == control.Variant.PRIMARY:
					check(face.get_margin(SIDE_LEFT) >= face.face.get_margin(SIDE_LEFT) + face.ornament_travel, "Primary layout reserves room for fully revealed ornaments")
				check(control.get_theme_color("icon_normal_color") == control.get_theme_color("font_color"), "Native icons inherit the label foreground")
				check(control.get_child_count() == 0, "Presentation adds no content or input nodes")
				check(control.get_combined_minimum_size().y >= (44 if compact else 52), "Native density target is retained")
				var events := []
				control.pressed.connect(func(): events.append(true))
				control.grab_focus()
				await _accept(true)
				await _accept(false)
				check(events.size() == 1 and control.has_focus(), "Native keyboard activation emits once and retains focus")
				control.disabled = true
				control.reduced_motion = true
				await _accept(true)
				await _accept(false)
				face = control.get_theme_stylebox("disabled")
				check(face.reveal == 0, "Disabled ornaments retract, including while focused")
				check(events.size() == 1, "Disabled actions cannot activate")
				check(control.icon == (null if content == "text" else Icon), "Theme preserves the caller's icon")
				control.free()
	await _motion_and_selection()
	await _overrides()
	host.free()
	if not capture_dir.is_empty() and DisplayServer.get_name() != "headless":
		await _capture_states()
	print("FANTASY_BUTTON: %d assertions; %d failures" % [assertions, failures.size()])
	quit(0 if failures.is_empty() else 1)

func _accept(down: bool) -> void:
	var event := InputEventAction.new()
	event.action = &"ui_accept"
	event.pressed = down
	root.push_input(event)
	await process_frame

func _motion_and_selection() -> void:
	var control = Scene.instantiate()
	control.variant = control.Variant.PRIMARY
	control.text = "Сохранить изменения — Änderungen speichern"
	control.icon = Icon
	control.toggle_mode = true
	host.add_child(control)
	await settle()
	control.set_process(false)
	var face = control.get_theme_stylebox("normal")
	var resting: float = face.face.expand_margin_top
	control.button_pressed = true
	control._process(0.01)
	var during_press: float = face.face.expand_margin_top
	check(during_press < resting and during_press > -5, "Press interpolates the original five-pixel depth")
	control.button_pressed = false
	control._process(0)
	check(is_equal_approx(face.face.expand_margin_top, during_press), "Reversing a press starts at its current position")
	control._process(0.2)
	check(is_equal_approx(face.face.expand_margin_top, resting), "Interrupted release settles at rest")
	control.grab_focus()
	control._process(0.05)
	check(face.reveal > 0.35 and face.reveal < 1, "Focus animates primary ornaments")
	control.button_pressed = true
	control.reduced_motion = true
	face = control.get_theme_stylebox("pressed")
	check(face.reveal == 1 and face.face.expand_margin_top == -5, "Reduced motion settles focus and press immediately")
	control.reduced_motion = false
	control.button_pressed = false
	control._process(0.01)
	var identity: int = control.get_instance_id()
	for selected_theme in [null, Fantasy, load("res://rookframe/ui/themes/cyberpunk/theme.tres"), Fantasy]:
		host.theme = selected_theme
		await settle()
		check(control.get_instance_id() == identity and control.has_focus() and control.icon == Icon, "Mid-motion theme changes retain native content and focus")
		check((control.get_theme_stylebox("normal") is CarvedStyle) == (selected_theme == Fantasy), "Carved appearance is scoped to the selected Fantasy theme")
	control.button_pressed = true
	control.variant = control.Variant.DESTRUCTIVE
	control.compact = true
	await settle()
	check(control.button_pressed and control.has_focus(), "Role and density changes retain selection and focus")
	check(control.get_theme_stylebox("normal").surface.texture == control.get_theme_icon("cap"), "Live destructive role uses the oxblood cap")
	var other = Scene.instantiate()
	host.add_child(other)
	check(other.get_theme_stylebox("normal") != control.get_theme_stylebox("normal"), "Motion resources are isolated per button")
	other.free()
	host.remove_child(control)
	host.theme = null
	host.add_child(control)
	await settle()
	check(not control.has_theme_stylebox_override("normal"), "Reparenting out of Fantasy restores native appearance")
	control.free()

func _capture_states() -> void:
	for canvas in [Vector2i(1920, 1080), Vector2i(1024, 768), Vector2i(844, 390)]:
		root.size = canvas
		root.content_scale_factor = 1.0
		for bright in [false, true]:
			var backdrop := ColorRect.new()
			backdrop.color = Color("ede7db") if bright else Color("171717")
			backdrop.size = canvas
			root.add_child(backdrop)
			var specimen := Control.new()
			specimen.theme = Fantasy
			specimen.position = Vector2((canvas.x - 800) / 2.0, (canvas.y - 350) / 2.0)
			backdrop.add_child(specimen)
			var caption := Label.new()
			caption.add_theme_color_override("font_color", Color("30281f") if bright else Color("eee5d5"))
			specimen.add_child(caption)
			var actions: Array[Button] = []
			for compact in [false, true]:
				for variant in 3:
					var control = Scene.instantiate()
					control.variant = variant
					control.compact = compact
					control.text = ["Continue", "Begin", "Delete"][variant]
					control.icon = Icon
					control.toggle_mode = true
					specimen.add_child(control)
					control.position = Vector2(variant * 270, 65 if not compact else 160)
					control.size.x = 250
					actions.append(control)
			var long_label = Scene.instantiate()
			long_label.variant = long_label.Variant.PRIMARY
			specimen.add_child(long_label)
			long_label.position = Vector2(0, 260)
			for state in ["rest", "active", "disabled"]:
				caption.text = "Fantasy · %s · normal / compact · %d × %d" % [state, canvas.x, canvas.y]
				long_label.text = {"rest": "Save all changes to the current draft", "active": "Сохранить изменения", "disabled": "Änderungen speichern"}[state]
				for control in actions:
					control.disabled = state == "disabled"
					control.button_pressed = state == "active" and control.variant == control.Variant.DESTRUCTIVE
				if state == "active":
					actions[1].grab_focus()
					var motion := InputEventMouseMotion.new()
					motion.position = actions[0].get_global_rect().get_center()
					root.push_input(motion)
				await create_timer(0.2).timeout
				await RenderingServer.frame_post_draw
				for control in actions + [long_label]:
					check(control.get_global_rect().end.x <= canvas.x, "Close-up buttons and translated content fit the canvas")
				var filename := "%dx%d-%s-%s.png" % [canvas.x, canvas.y, "light" if bright else "dark", state]
				check(root.get_texture().get_image().save_png(capture_dir.path_join(filename)) == OK, "Capture " + filename)
			backdrop.free()
			await process_frame

func _overrides() -> void:
	host.theme = Fantasy
	var control = Scene.instantiate()
	var custom := StyleBoxFlat.new()
	custom.bg_color = Color.REBECCA_PURPLE
	control.add_theme_stylebox_override("hover", custom)
	control.add_theme_color_override("font_outline_color", Color.RED)
	host.add_child(control)
	await settle()
	check(control.get_theme_stylebox("hover") == custom, "Pre-existing local style overrides retain priority")
	check(control.get_theme_color("font_outline_color") == Color.RED, "Pre-existing ink overrides retain priority")
	control.add_theme_stylebox_override("normal", custom)
	host.theme = null
	await settle()
	check(control.get_theme_stylebox("normal") == custom and control.get_theme_stylebox("hover") == custom, "Later caller writes survive removing the theme")
	check(not control.has_theme_stylebox_override("pressed") and not control.has_theme_constant_override("outline_size"), "Presentation-owned overrides are removed")
	control.free()
