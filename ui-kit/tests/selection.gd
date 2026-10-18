extends SceneTree
## Shared choices preserve native selection across presentation changes.
const Choice = preload("res://rookframe/ui/components/forms/choice.tscn")
const Select = preload("res://rookframe/ui/components/forms/select.tscn")
var failures: Array[String] = []
var events: Array = []

func _initialize() -> void:
	_run.call_deferred()

func check(condition: bool, message: String) -> void:
	if not condition: failures.append(message)

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
	var host := VBoxContainer.new()
	root.add_child(host)
	host.size = Vector2(600, 760)
	var first = Choice.instantiate()
	var second = Choice.instantiate()
	host.add_child(first)
	host.add_child(second)
	first.selection_changed.connect(func(value: bool): events.append(value))
	await press(first)
	check(first.button_pressed and events == [true], "Independent choice activates once")
	await press(first)
	check(not first.button_pressed and events == [true, false], "Independent choice clears once")
	var group: ButtonGroup = load("res://rookframe/ui/components/forms/selection_group.tres").duplicate()
	first.button_group = group
	second.button_group = group
	first.button_pressed = true
	await press(second)
	check(second.button_pressed and not first.button_pressed, "Exclusive choices share native rules")
	await press(second)
	check(second.button_pressed, "Required group cannot clear its selection")
	group.allow_unpress = true
	await press(second)
	check(group.get_pressed_button() == null, "Optional group can clear its selection")
	first.button_group = null
	first.set_pressed_no_signal(true)
	first.title = "A long translated title that must wrap at a narrow width"
	first.description = "Supporting copy remains available independently of density."
	first.accessibility_name = "Caller name"
	first.accessibility_description = "Caller description"
	var before := events.size()
	for variant in range(5):
		first.variant = variant
		first.compact = true
		first.show_description = true
		await process_frame
		check(first.button_pressed and events.size() == before, "Presentation preserves selection without signals")
		check(first.get_node("Content/Row/Copy/Description").visible, "Compact density retains supporting copy")
		check(first.accessibility_name == "Caller name" and first.accessibility_description == "Caller description", "Explicit accessibility copy survives variants")
	first.show_description = false
	check(not first.get_node("Content/Row/Copy/Description").visible, "Description visibility is independent")
	first.variant = first.Variant.MARKED_CARD
	first.selected_label = "Included"
	check(first.get_node("Content/Row/State").text == "Included", "Host owns selected copy")
	first.disabled = true
	await press(first)
	check(first.button_pressed and events.size() == before, "Disabled choice rejects activation")
	var select = Select.instantiate()
	host.add_child(select)
	select.add_item("First", 11)
	select.add_item("Second", 22)
	select.select(1)
	select.variant = select.Variant.MENU
	select.compact = true
	select.variant = select.Variant.NATIVE
	check(select.get_selected_id() == 22, "Select presentation preserves native IDs and selection")
	check(select.theme_type_variation == &"" and select.get_popup().theme == null, "Native select restores stock presentation")
	host.free()
	for failure in failures: push_error(failure)
	print("SELECTION: %d failures" % failures.size())
	quit(0 if failures.is_empty() else 1)
