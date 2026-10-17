extends SceneTree
## Public native proxies preserve Godot input and state through installed paths.
const UI := "res://rookframe/ui/components/"
var failures: Array[String] = []
var assertions := 0
var host: VBoxContainer

func _initialize() -> void:
	_run.call_deferred()

func check(condition: bool, message: String) -> void:
	assertions += 1
	if not condition:
		failures.append(message)

func mount(path: String) -> Node:
	var control = load(UI + path).instantiate()
	host.add_child(control)
	return control

func press(control: Control) -> void:
	control.grab_focus()
	await process_frame
	for down in [true, false]:
		var event := InputEventAction.new()
		event.action = &"ui_accept"
		event.pressed = down
		root.push_input(event)
		await process_frame

func _run() -> void:
	root.gui_embed_subwindows = true
	root.size = Vector2i(1024, 768)
	host = VBoxContainer.new()
	root.add_child(host)
	host.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_catalogue()
	await _buttons_and_groups()
	await _retained_content()
	_avatar()
	print("NATIVE_PROXIES: %d assertions; %d failures" % [assertions, failures.size()])
	for failure in failures:
		push_error(failure)
	quit(0 if failures.is_empty() else 1)

func _catalogue() -> void:
	var catalogue = JSON.parse_string(FileAccess.get_file_as_string("res://rookframe/ui/catalogue.json"))
	var count := 0
	var paths := {}
	var uids := {}
	for entry in catalogue.components:
		if not entry.get("nativeProxy", false):
			continue
		count += 1
		var path: String = entry.get("scene", entry.get("resource", ""))
		var uid: String = entry.get("sceneUid", entry.get("resourceUid", ""))
		check(not paths.has(path) and not uids.has(uid), "Unique public path and UID: " + path)
		paths[path] = true
		uids[uid] = true
		check(ResourceUID.id_to_text(ResourceLoader.get_resource_uid(path)) == uid, "Installed UID: " + path)
		var resource = load(path)
		check(resource != null, "Load public proxy: " + path)
		if resource is PackedScene:
			var node = resource.instantiate()
			check(node.is_class(entry.rootType), "Native root: " + path)
			check(node.theme == null, "No appearance selected: " + path)
			if not entry.has("inherits") and not entry.has("script"):
				check(node.get_script() == null, "Native proxy needs no behavior script: " + path)
			node.free()
		else:
			check(resource.is_class(entry.rootType) and resource.resource_local_to_scene, "Native group is local to its owning scene: " + path)
	check(count == 33, "All native recipes and orientation variants are addressable")

func _buttons_and_groups() -> void:
	var button: Button = mount("actions/button.tscn")
	button.text = "Action"
	var events := []
	button.pressed.connect(func(): events.append(true))
	await press(button)
	check(events.size() == 1, "Native keyboard activation emits once")
	button.disabled = true
	await press(button)
	check(events.size() == 1, "Disabled proxy does not activate")
	button.free()
	var checkbox: CheckBox = mount("forms/checkbox.tscn")
	checkbox.text = "Include"
	var changes := []
	checkbox.toggled.connect(func(value): changes.append(value))
	await press(checkbox)
	check(checkbox.button_pressed and changes == [true], "Checkbox retains native toggle signal")
	checkbox.free()
	var first: Button = mount("actions/toggle.tscn")
	var second: Button = mount("actions/toggle.tscn")
	first.text = "First"
	second.text = "Second"
	var group: ButtonGroup = load(UI + "actions/toggle_group.tres").duplicate()
	first.button_group = group
	second.button_group = group
	first.button_pressed = true
	await press(second)
	check(second.button_pressed and not first.button_pressed, "Native group switches exclusive selection")
	await press(second)
	check(second.button_pressed, "Required native group retains selection")
	group.allow_unpress = true
	await press(second)
	check(group.get_pressed_button() == null, "Optional native group permits no selection")
	var independent: ButtonGroup = load(UI + "actions/toggle_group.tres").duplicate()
	check(not independent.allow_unpress and independent.get_buttons().is_empty(), "Runtime groups are independent")
	first.free()
	second.free()
	var radio: CheckBox = mount("forms/checkbox.tscn")
	radio.button_group = load(UI + "forms/radio_group.tres").duplicate()
	radio.text = "Radio"
	await press(radio)
	check(radio.button_group.get_pressed_button() == radio, "Radio group uses native Checkbox selection")
	radio.free()

func _retained_content() -> void:
	var tabs: TabContainer = mount("navigation/tabs.tscn")
	var first := VBoxContainer.new()
	var second := VBoxContainer.new()
	tabs.add_child(first)
	tabs.add_child(second)
	var editor: LineEdit = load(UI + "forms/input.tscn").instantiate()
	editor.text = "Retained draft"
	first.add_child(editor)
	editor.select(0, 8)
	tabs.current_tab = 1
	tabs.current_tab = 0
	check(editor.text == "Retained draft" and editor.get_selected_text() == "Retained", "Tabs retain native editor and selection")
	editor.editable = false
	check(editor.get_selected_text() == "Retained", "Read-only native input retains selection")
	tabs.set_tab_disabled(1, true)
	check(tabs.is_tab_disabled(1), "Tabs expose native disabled state")
	tabs.free()
	var a: FoldableContainer = mount("surfaces/collapsible.tscn")
	var b: FoldableContainer = mount("surfaces/collapsible.tscn")
	var group: FoldableGroup = load(UI + "surfaces/accordion.tres").duplicate()
	a.foldable_group = group
	b.foldable_group = group
	var notes: TextEdit = load(UI + "forms/textarea.tscn").instantiate()
	notes.text = "Retained notes"
	a.add_child(notes)
	a.folded = true
	a.folded = false
	b.folded = false
	check(a.folded and not b.folded, "Accordion delegates single-open state to FoldableGroup")
	a.folded = false
	check(notes.text == "Retained notes", "Folding retains native editor content")
	a.free()
	b.free()
	var spinner = mount("feedback/spinner.tscn")
	spinner.reduced_motion = true
	check(spinner.state == 0 and not spinner.is_processing(), "Spinner reuses TaskState reduced-motion behavior")
	spinner.free()

func _avatar() -> void:
	var avatar = mount("data/avatar.tscn")
	var image: TextureRect = avatar.get_node("Image")
	var initials: Label = avatar.get_node("Initials")
	check(image.visible and image.texture != null and not initials.visible, "Avatar defaults to fallback image")
	avatar.initials = "AR"
	check(initials.visible and initials.text == "AR" and not image.visible, "Initials replace missing art")
	var texture := GradientTexture2D.new()
	avatar.texture = texture
	check(image.visible and image.texture == texture and not initials.visible, "Supplied image takes priority")
	avatar.texture = null
	check(initials.visible, "Removing art restores retained initials")
	avatar.initials = ""
	check(image.visible and image.texture == avatar.fallback_texture, "Removing initials restores fallback")
	avatar.free()
