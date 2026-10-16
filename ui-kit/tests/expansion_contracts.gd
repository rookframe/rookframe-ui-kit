extends SceneTree
## Public contract assertions. Private row access is limited to identity checks.
const UI := "res://rookframe/ui/"
var failures: Array[String] = []
var assertions := 0
var host: Control

func _initialize() -> void:
	_run.call_deferred()

func check(value: bool, message: String) -> void:
	assertions += 1
	if not value: failures.append(message)

func mount(path: String) -> Node:
	var scene = load(UI + path)
	if scene == null:
		failures.append("Cannot load " + path)
		return null
	var node = scene.instantiate()
	host.add_child(node)
	return node

func settle(frames := 4) -> void:
	for i in frames: await process_frame

func press(control: Control) -> void:
	control.grab_focus()
	await process_frame
	for down in [true, false]:
		var event := InputEventAction.new()
		event.action = &"ui_accept"
		event.pressed = down
		root.push_input(event)
		await process_frame

func named(node: Node, copy: String) -> Control:
	if node is Control and node.accessibility_name == copy: return node
	for child in node.get_children():
		var found := named(child, copy)
		if found != null: return found
	return null

func _run() -> void:
	root.content_scale_size = Vector2i.ZERO
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	root.size = Vector2i(1024, 768)
	root.gui_embed_subwindows = true
	host = Control.new()
	root.add_child(host)
	host.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	await _field()
	await _picker()
	await _popover()
	await _toast()
	await _collections()
	await _transfer()
	await _lifetime()
	print("EXPANSION_CONTRACTS: ", assertions, " assertions; ", failures.size(), " failures; Godot ", Engine.get_version_info().string)
	for failure in failures: push_error(failure)
	quit(0 if failures.is_empty() else 1)

func _field() -> void:
	var field = mount("components/forms/field.tscn")
	field.size = Vector2(500, 220)
	var editor := LineEdit.new()
	editor.text = "Retained editor content"
	editor.custom_minimum_size.y = 44
	editor.accessibility_name = "Original name"
	field.get_input_slot().add_child(editor)
	check(field.get_input_slot() == field.get_node("%InputSlot"), "AT-44 Field unique slot")
	check(field.set_target(editor), "AT-07 Field accepts slotted editor")
	field.label_text = "Name"
	field.help_text = "Host help"
	await settle()
	check(field.focus_input(), "Field enters native focus")
	editor.caret_column = 7
	editor.select(2, 5)
	field.set_error("Host error")
	check(editor.text == "Retained editor content" and editor.get_selection_from_column() == 2 and editor.get_selection_to_column() == 5 and editor.caret_column == 7 and editor.has_focus(), "AT-07 Error preserves editor state")
	check(editor.accessibility_name == "Name" and editor.accessibility_description.contains("Host help") and editor.accessibility_description.contains("Error:"), "Field accessibility relationship")
	var other := LineEdit.new()
	host.add_child(other)
	check(not field.set_target(other), "AT-41 Foreign target rejected")
	check(editor.accessibility_name == "Name", "Rejected association is atomic")
	field.label_visible = false
	check(editor.accessibility_name == "Name", "Hidden label still names editor")
	check(field.set_target(null) and editor.accessibility_name == "Original name", "Field restores prior association")
	check(not field.focus_input(), "Field without target cannot focus")
	other.free()
	var group := VBoxContainer.new()
	field.get_input_slot().add_child(group)
	var choice := CheckBox.new()
	choice.accessibility_name = "Individual choice"
	group.add_child(choice)
	check(field.set_target(group), "AT-08 Group target accepted")
	check(choice.accessibility_name == "Individual choice" and group.accessibility_name == "Name", "Group retains individual names")
	var input_group = mount("components/forms/input_group.tscn")
	for pair in [["LeadingSlot", input_group.get_leading_slot()], ["InputSlot", input_group.get_input_slot()], ["TrailingSlot", input_group.get_trailing_slot()]]:
		check(input_group.get_node("%" + pair[0]) == pair[1], "AT-44 InputGroup " + pair[0])
	var retained := Button.new()
	input_group.get_trailing_slot().add_child(retained)
	input_group.theme = Theme.new()
	check(retained.get_parent() == input_group.get_trailing_slot(), "AT-09 Retained action after theme change")
	input_group.free()
	field.free()

func _picker() -> void:
	var picker = mount("components/forms/multi_select_picker.tscn")
	picker.size = Vector2(500, 400)
	var events: Array = []
	picker.selection_changed.connect(func(ids: PackedStringArray): events.append(ids))
	var items: Array[Dictionary] = [{"id": "a", "title": "Alpha"}, {"id": "b", "title": "Beta"}, {"id": "c", "title": "Locked", "disabled": true}]
	check(picker.set_items(items), "Picker accepts records")
	check(picker.set_selected_ids(PackedStringArray(["a", "c"])), "Host selects enabled and disabled records")
	check(events.is_empty(), "AT-11 Setters are silent")
	check(not picker.set_selected_ids(PackedStringArray(["missing"])) and not picker.set_selected_ids(PackedStringArray(["a", "a"])), "Picker rejects unknown and duplicate IDs")
	var duplicate: Array[Dictionary] = [{"id": "a", "title": "One"}, {"id": "a", "title": "Two"}]
	check(not picker.set_items(duplicate), "Picker rejects duplicate records")
	check(picker.get_selected_ids() == PackedStringArray(["a", "c"]), "Invalid update leaves selection intact")
	await settle()
	await press(named(picker, "Beta"))
	check(events.size() == 1 and picker.get_selected_ids() == PackedStringArray(["a", "b", "c"]), "AT-10 Native activation changes once")
	await press(named(picker, "Remove Alpha"))
	check(events.size() == 2 and picker.get_selected_ids() == PackedStringArray(["b", "c"]), "AT-10 Remove changes once")
	var clear: Button
	for button in picker.find_children("*", "Button", true, false):
		if button.text == "Clear selection": clear = button
	await press(clear)
	check(events.size() == 3 and picker.get_selected_ids() == PackedStringArray(["c"]), "AT-12 Clear retains disabled selection")
	check(clear.disabled, "Clear unavailable with only locked selection")
	var copy: PackedStringArray = picker.get_selected_ids()
	copy.clear()
	check(picker.get_selected_ids().size() == 1 and items[0].id == "a", "Picker returns independent selection and preserves input")
	var empty: Array[Dictionary] = []
	picker.set_items(empty)
	check(picker.get_selected_ids().is_empty() and events.size() == 3, "Reconciliation is silent")
	picker.free()

func _popover() -> void:
	var anchor := Button.new()
	anchor.text = "Inspect"
	anchor.size = Vector2(100, 44)
	host.add_child(anchor)
	var popup = mount("components/overlays/popover.tscn")
	var action := Button.new()
	action.text = "Use"
	action.custom_minimum_size = Vector2(120, 44)
	popup.get_content_slot().add_child(action)
	var closed: Array = []
	popup.closed.connect(func(reason: StringName): closed.append(reason))
	check(popup.get_content_slot() == popup.get_node("%ContentSlot"), "AT-44 Popover slot")
	for point in [Vector2(0, 0), Vector2(900, 0), Vector2(0, 700), Vector2(900, 700)]:
		anchor.position = point
		check(popup.open_for(anchor, action), "AT-13 Popup opens at corner")
		await settle()
		check(popup.position.x >= 0 and popup.position.y >= 0 and popup.position.x + popup.size.x <= root.size.x and popup.position.y + popup.size.y <= root.size.y, "AT-13 Popup bounded %s %s in %s" % [popup.position, popup.size, root.size])
		popup.close()
	check(closed.size() == 4, "One close per operation")
	popup.close()
	check(closed.size() == 4, "Repeated close is silent")
	check(not popup.open_for(anchor, anchor), "AT-41 Foreign initial focus rejected")
	popup.open_for(anchor)
	anchor.hide()
	await settle()
	check(not popup.is_open() and closed.back() == &"anchor_lost", "AT-14 Anchor hiding closes")
	anchor.show()
	popup.open_for(anchor)
	anchor.free()
	await settle()
	check(not popup.is_open(), "AT-14 Freed anchor closes safely")
	check(action.get_parent() == popup.get_content_slot(), "Popover retains caller content")
	popup.free()

func _toast() -> void:
	var stack = mount("components/feedback/toast_stack.tscn")
	var events: Array = []
	stack.finished.connect(func(id: String, reason: StringName, action: String): events.append([id, reason, action]))
	for i in 23: check(stack.push({"id": str(i), "title": "Message", "duration_ms": 0}), "AT-18 Accept capacity " + str(i))
	check(not stack.push({"id": "overflow", "title": "No"}), "AT-18 Overflow rejected")
	check(stack.get_child_count() == 3, "AT-18 Three visible")
	check(not stack.configure_limits(2, 20) and not stack.configure_limits(3, 19), "AT-42 Shrinking occupied limits rejected")
	check(not stack.update_message("0", {"id": "new"}) and not stack.update_message("0", {"duration_ms": -1}), "AT-42 Invalid update is atomic")
	check(stack.update_message("0", {"title": "Changed"}), "Toast update accepted")
	check(stack.dismiss("0") and not stack.dismiss("0"), "Dismiss is terminal once")
	check(events.size() == 1 and events[0][1] == &"host", "Toast host reason")
	var promoted: Array = []
	stack.child_entered_tree.connect(func(card: Node): promoted.append(card.get_instance_id()))
	stack.clear()
	check(events.size() == 23 and stack.get_child_count() == 0, "Clear finishes each accepted message once")
	check(promoted.is_empty(), "Clear never promotes waiting messages")
	check(stack.push({"id": "action", "title": "Saved", "action_id": "undo", "action_label": "Undo"}), "Action defaults to persistent")
	await settle()
	var action := named(stack, "Undo")
	await press(action)
	check(events.size() == 24 and events.back() == ["action", &"action", "undo"], "AT-20 Native action finishes once")
	check(not stack.dismiss("action"), "Finished action cannot repeat")
	stack.free()
	var timed = preload("fixtures/toast_clock.gd").new()
	host.add_child(timed)
	timed.position = Vector2(600, 500)
	var timed_events: Array = []
	timed.finished.connect(func(id: String, _reason: StringName, _action: String): timed_events.append(id))
	timed.push({"id": "clock", "title": "Clock", "duration_ms": 100})
	timed.timers_paused = true
	timed.advance(500)
	await settle()
	check(timed_events.is_empty(), "AT-19 Explicit timer pause")
	timed.timers_paused = false
	timed.hide()
	timed.advance(500)
	await settle()
	check(timed_events.is_empty(), "AT-19 Hidden timer pause")
	timed.show()
	timed.advance(40)
	await settle()
	timed.update_message("clock", {"description": "Updated"})
	timed.advance(61)
	await settle()
	check(timed_events == ["clock"], "AT-42 Update preserves elapsed time")
	timed.free()

func _collections() -> void:
	for path in ["components/data/paginated_choices.tscn", "components/data/collection.tscn"]:
		var collection = mount(path)
		collection.size = Vector2(600, 400)
		collection.size_flags_vertical = Control.SIZE_EXPAND_FILL
		var entries: Array[Dictionary] = []
		for i in 12: entries.append({"id": str(i), "title": "Record " + str(i)})
		collection.configure(entries, "1")
		await settle(8)
		var rows: Array = collection._rows.duplicate()
		check(collection.focus_entry("1"), "Collection focuses record")
		entries.reverse()
		collection.configure(entries, "1")
		await settle(8)
		check(collection._rows[10] == rows[1], "AT-22 Reordered record keeps row identity")
		check(collection.focus_entry("1"), "Retained record remains focusable")
		var focused := root.gui_get_focus_owner()
		var larger := Theme.new()
		larger.default_font_size = 30
		collection.theme = larger
		await settle(8)
		check(root.gui_get_focus_owner() == focused and focused.is_visible_in_tree(), "AT-32 Theme changes preserve retained focus")
		collection.set_visible_ids(PackedStringArray(["3", "4"]))
		await settle(8)
		check(not collection.focus_entry("1"), "Filtered record not focusable")
		collection.reset_filter()
		await settle(8)
		check(collection.focus_entry("1"), "AT-23 Filter restoration retains record")
		var footer := Button.new()
		footer.text = "Host footer"
		collection.get_footer_slot().add_child(footer)
		var state: Dictionary = collection.capture_state()
		collection.restore_state(state)
		await settle(8)
		check(footer.get_parent() == collection.get_footer_slot(), "AT-26 Footer identity retained")
		entries = [{"id": "remaining", "title": "Remaining"}]
		collection.configure(entries, "")
		await settle(8)
		check(collection.capture_state().page == 0, "AT-24 Page clamped after removal")
		collection.free()
	var large = mount("components/data/paginated_choices.tscn")
	large.size = Vector2(800, 600)
	var records: Array[Dictionary] = []
	for i in 1000: records.append({"id": str(i), "title": "Record " + str(i)})
	large.configure(records, "0")
	await settle(8)
	var identities: Array = large._rows.duplicate()
	var start := Time.get_ticks_usec()
	for i in 100:
		records[i].title = "Updated " + str(i)
		large.configure(records, "0")
	var updated := Time.get_ticks_usec()
	await settle(8)
	print("AT-37 1000 records / 100 updates: update_us=", updated - start, "; settle_us=", Time.get_ticks_usec() - updated)
	check(large._rows == identities, "AT-37 Single-record edits retain all rows")
	large.free()

func _transfer() -> void:
	var region := Control.new()
	host.add_child(region)
	var context := RookframeTransferContext.new()
	region.add_child(context)
	var source = load(UI + "components/data/drag_slot.tscn").instantiate()
	source.context = context
	source.slot_id = "source"
	source.payload = {"item": "item-1", "nested": {"amount": 2}}
	region.add_child(source)
	var target = load(UI + "components/data/drag_slot.tscn").instantiate()
	target.context = context
	target.slot_id = "target"
	region.add_child(target)
	context.placement_validator = func(_source: String, _target: String, _payload: Dictionary): return {"allowed": true, "reason": ""}
	var requests: Array = []
	context.transfer_requested.connect(func(id: int, from: String, to: String, payload: Dictionary): requests.append([id, from, to, payload]))
	check(context.begin_transfer("source") and not context.begin_transfer("source"), "DRG one operation per region")
	source.payload = {"item": "changed"}
	check(not context.evaluate_target("source").allowed, "Source cannot target itself")
	var id := context.request_placement("target")
	check(id > 0 and context.get_state() == &"pending" and requests.size() == 1, "AT-27 Validated request becomes pending")
	check(requests[0][3].item == "item-1", "Transfer snapshots payload")
	check(context.request_placement("target") == 0 and not context.cancel_transfer(), "Pending cannot duplicate or revoke request")
	check(not context.resolve_transfer(id + 1, true), "AT-30 Unknown result ignored")
	check(context.resolve_transfer(id, false, "Try another slot") and context.get_state() == &"carrying", "Rejected result returns to carrying")
	var second := context.request_placement("target")
	check(second > id and not context.resolve_transfer(id, true), "Old result ignored")
	check(context.resolve_transfer(second, true) and context.get_state() == &"idle", "Matching result completes")
	check(not context.resolve_transfer(second, true), "Duplicate result ignored")
	context.transfer_requested.connect(func(request: int, _from: String, _to: String, _payload: Dictionary): context.resolve_transfer(request, true))
	context.begin_transfer("source")
	var sync := context.request_placement("target")
	check(sync > second and context.get_state() == &"idle", "AT-43 Synchronous resolution keeps issued ID")
	context.begin_transfer("source")
	source.hide()
	await settle()
	check(context.get_state() == &"idle", "AT-29 Source hiding cancels carrying")
	check(source.get_content_slot() == source.get_node("%ContentSlot"), "AT-44 DragSlot unique slot")
	region.free()

func _lifetime() -> void:
	var before := host.get_child_count()
	for i in 100:
		for path in ["forms/field", "forms/input_group", "forms/multi_select_picker", "overlays/popover", "overlays/inspect_card", "feedback/toast_stack", "data/drag_slot"]:
			var component = mount("components/" + path + ".tscn")
			component.free()
	await settle()
	check(host.get_child_count() == before, "AT-36 100 create/free cycles retain no owned children")
