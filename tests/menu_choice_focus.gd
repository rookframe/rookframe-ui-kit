extends SceneTree
## Render the native focus state: flat pale bars must not cover the walnut face.
const Choice = preload("res://rookframe/ui/menu/MenuChoice.tscn")
const Fantasy = preload("res://rookframe/ui/menu/MenuTheme.tres")
var failures: Array[String] = []
var capture_dir := "/tmp/menu-choice-focus"


func _initialize() -> void:
	call_deferred("verify")


func settle() -> void:
	for frame in range(5):
		await process_frame


func check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
		push_error(message)


func snapshot(choice: Control, name: String) -> Image:
	await settle()
	RenderingServer.force_draw(false)
	var bounds := Rect2i(choice.get_global_rect())
	var result := root.get_texture().get_image().get_region(bounds)
	result.save_png(capture_dir.path_join(name + ".png"))
	return result


func longest_pale_bar(image: Image, baseline: Image) -> int:
	var longest := 0
	for y in range(image.get_height()):
		var run := 0
		for x in range(image.get_width()):
			var pixel := image.get_pixel(x, y)
			var before := baseline.get_pixel(x, y)
			if pixel.r > 0.93 and pixel.g > 0.86 and pixel.b > 0.60 and pixel.get_luminance() > before.get_luminance() + 0.15:
				run += 1
				longest = maxi(longest, run)
			else:
				run = 0
	return longest


func check_focus_image(focused: Image, normal: Image, label: String) -> void:
	var length := longest_pale_bar(focused, normal)
	check(length < focused.get_width() / 2, label + ": focus painted a pale bar " + str(length) + " px wide")
	# Removing focus altogether must not pass: both walnut edges must visibly
	# respond, beyond the native label's text-color change in the middle.
	for right in [false, true]:
		var lit := 0
		var end_width := focused.get_width() / 10
		for y in range(focused.get_height()):
			for offset in range(end_width):
				var x := focused.get_width() - 1 - offset if right else offset
				if focused.get_pixel(x, y).get_luminance() > normal.get_pixel(x, y).get_luminance() + 0.06:
					lit += 1
		check(lit > end_width * focused.get_height() * 0.05, label + ": focus is not visible on the " + ("right" if right else "left") + " edge")


func move_pointer(position: Vector2) -> void:
	var event := InputEventMouseMotion.new()
	event.position = position
	event.global_position = position
	root.push_input(event, true)
	await settle()


func enter() -> void:
	for pressed in [true, false]:
		var event := InputEventKey.new()
		event.keycode = KEY_ENTER
		event.pressed = pressed
		root.push_input(event)
	await settle()


func verify() -> void:
	if DisplayServer.get_name() == "headless":
		push_error("Focus regression requires a graphical renderer")
		quit(1)
		return
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--capture-dir="):
			capture_dir = argument.trim_prefix("--capture-dir=")
	DirAccess.make_dir_recursive_absolute(capture_dir)
	root.size = Vector2i(960, 640)
	root.content_scale_size = root.size
	root.gui_embed_subwindows = true
	root.unfocusable = true
	root.mouse_passthrough = true
	var choice := Choice.instantiate() as OptionButton
	choice.theme = Fantasy
	root.add_child(choice)
	choice.add_item("English")
	choice.add_item("Deutsch")
	choice.position = Vector2(100, 80)
	for factor in [1.0, 1.25]:
		choice.scale = Vector2.ONE * factor
		for compact in [false, true]:
			choice.set_compact(compact)
			await settle()
			choice.size = Vector2(400, choice.get_theme_constant("minimum_height"))
			var label := ("compact" if compact else "regular") + ("-scaled" if factor > 1.0 else "")
			for hover in [false, true]:
				await move_pointer(choice.get_global_rect().get_center() if hover else Vector2(20, 20))
				choice.release_focus()
				var state := label + ("-hover" if hover else "")
				var normal := await snapshot(choice, state + "-normal")
				choice.grab_focus()
				var focused := await snapshot(choice, state + "-focused")
				check_focus_image(focused, normal, state)
			await move_pointer(Vector2(20, 20))
			await enter()
			check(choice.get_popup().visible and choice.get_draw_mode() == BaseButton.DRAW_PRESSED, label + ": native pressed state did not open")
			var pressed_focus := await snapshot(choice, label + "-pressed-focused")
			choice.release_focus()
			var pressed_normal := await snapshot(choice, label + "-pressed-normal")
			check_focus_image(pressed_focus, pressed_normal, label + "-pressed")
			choice.get_popup().hide()
			await settle()
			choice.disabled = true
			var disabled_focus := await snapshot(choice, label + "-disabled-focused")
			choice.release_focus()
			var disabled_normal := await snapshot(choice, label + "-disabled-normal")
			check(disabled_focus.get_data() == disabled_normal.get_data(), label + ": disabled field retained a focus highlight")
			choice.disabled = false
	choice.queue_free()
	await settle()
	print("MENU_CHOICE_FOCUS ", "PASS" if failures.is_empty() else failures)
	quit(0 if failures.is_empty() else 1)
