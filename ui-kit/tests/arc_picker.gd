extends SceneTree
## ArcTrack and ArcPicker keep the placement, overflow, input and record contracts.
const UI := "res://rookframe/ui/components/navigation/"
const Icon = preload("res://rookframe/ui/icons/check.svg")
var failures: Array[String] = []
var assertions := 0
var host: Control

func _initialize() -> void:
	_run.call_deferred()

func check(condition: bool, message: String) -> void:
	assertions += 1
	if not condition:
		failures.append(message)

func settle() -> void:
	for frame in 3:
		await process_frame

func _run() -> void:
	root.gui_embed_subwindows = true
	host = Control.new()
	root.add_child(host)
	host.size = host.get_viewport_rect().size
	await _track_placement()
	await _track_overflow()
	await _track_keyboard()
	await _picker_records()
	await _picker_choice()
	await _picker_keyboard()
	await _picker_dismissal()
	await _picker_fit()
	for failure in failures: push_error(failure)
	print("ARC_PICKER: %d assertions; %d failures" % [assertions, failures.size()])
	quit(0 if failures.is_empty() else 1)

func track(count: int, properties: Dictionary = {}) -> Container:
	var control: Container = load(UI + "arc_track.tscn").instantiate()
	for key in properties: control.set(key, properties[key])
	for index in count:
		var button := Button.new()
		button.custom_minimum_size = Vector2(48, 48)
		button.text = str(index)
		control.add_child(button)
	host.add_child(control)
	return control

func center(control: Control) -> Vector2:
	return control.position + control.size * 0.5

func _track_placement() -> void:
	var rail := track(4, {"pivot": Vector2(300, 300), "radius": 120.0, "start_angle": 180.0, "end_angle": 360.0})
	await settle()
	check(rail.theme == null and rail.theme_type_variation == &"RookframeArcTrack", "Track selects no appearance")
	check(rail.mouse_filter == Control.MOUSE_FILTER_IGNORE, "Track background never blocks the scene")
	var previous := -INF
	for entry in rail.get_children():
		var offset: Vector2 = center(entry) - rail.pivot
		check(absf(offset.length() - 120.0) < 1.0, "Entry centre sits on the arc")
		var angle := fposmod(rad_to_deg(offset.angle()), 360.0)
		angle = 180.0 if angle < 1.0 and previous == -INF else angle
		check(angle > previous, "Entries follow source order along the sweep")
		previous = angle
		check(entry.size == entry.get_combined_minimum_size(), "Entries keep their own minimum size")
	check(not rail.can_scroll(-1) and not rail.can_scroll(1), "A sweep that fits everything has no arrowheads")
	var reach: Vector2 = rail.get_combined_minimum_size()
	check(reach.x >= 300 + 120 and reach.y >= 300, "Minimum size covers the ring from the local origin")
	rail.reveal = 0.0
	await settle()
	for entry in rail.get_children():
		check(center(entry).distance_to(rail.pivot + Vector2.LEFT * 120.0) < 1.0, "Reveal 0 gathers entries at the start")
	rail.reveal = 1.0
	rail.end_angle = 540.0
	rail.alignment = rail.Alignment.CENTER
	await settle()
	var first: float = fposmod(rad_to_deg((center(rail.get_child(0)) - rail.pivot).angle()), 360.0)
	var last: float = fposmod(rad_to_deg((center(rail.get_child(3)) - rail.pivot).angle()), 360.0)
	check(absf(fposmod(first - 180.0, 360.0) - fposmod(540.0 - last, 360.0)) < 1.0, "Centre alignment balances a track that fits")
	rail.alignment = rail.Alignment.BEGIN
	rail.end_angle = 0.0
	rail.start_angle = 180.0
	rail.reveal = 1.0
	await settle()
	check(center(rail.get_child(1)).y > rail.pivot.y, "An end below the start runs counter-clockwise")
	rail.free()

func _track_overflow() -> void:
	# 90 degrees at radius 120 is about 188px: three 48px entries with 8px gaps.
	var rail := track(6, {"pivot": Vector2(300, 300), "radius": 120.0, "start_angle": 180.0, "end_angle": 270.0})
	var hidden: Control = rail.get_child(4)
	hidden.visible = false
	await settle()
	check(rail.get_placed_entries().size() == 3, "Only entries that fit are placed")
	check(rail.can_scroll(1) and not rail.can_scroll(-1), "Overflow marks the end as scrollable")
	check(not rail.get_child(3).visible and rail.get_entries().size() == 5, "Overflowed entries hide; caller-hidden ones are not entries")
	var scrolled := []
	rail.scrolled.connect(func(index: int): scrolled.append(index))
	check(rail.scroll_by(1) and rail.first_index == 1, "Scrolling advances one entry")
	check(scrolled == [1], "Scrolling reports the first index")
	check(not rail.get_child(0).visible and rail.get_child(3).visible, "Scrolling swaps the entries on the rail")
	check(rail.can_scroll(-1), "Scrolled start becomes scrollable")
	check(rail.ensure_visible(rail.get_child(5)), "Ensure visible accepts own entries")
	check(rail.get_child(5).visible and not hidden.visible, "Ensure visible scrolls to the entry; caller-hidden stays hidden")
	check(not rail.scroll_by(1), "Scrolling stops at the end")
	check(rail.get_child(5).get_parent() == rail and rail.get_child(5).get_index() == 5, "Children keep parent and index")
	check(not rail.ensure_visible(Button.new()), "Ensure visible rejects foreign entries")
	var wheel := InputEventMouseButton.new()
	wheel.button_index = MOUSE_BUTTON_WHEEL_UP
	wheel.pressed = true
	rail.get_child(5).gui_input.emit(wheel)
	check(rail.first_index == 1, "Wheel scrolls the track")
	rail.free()

func _track_keyboard() -> void:
	var rail := track(6, {"pivot": Vector2(300, 300), "radius": 120.0, "start_angle": 180.0, "end_angle": 270.0})
	rail.get_child(1).disabled = true
	await settle()
	var seen := []
	rail.highlighted.connect(func(entry: Control): seen.append(entry))
	rail.get_child(0).grab_focus()
	check(seen == [rail.get_child(0)], "Focus highlights the entry")
	await _action(&"ui_right")
	check(root.gui_get_focus_owner() == rail.get_child(2), "Right skips disabled entries in source order")
	await _action(&"ui_right")
	await _action(&"ui_right")
	check(root.gui_get_focus_owner() == rail.get_child(4) and rail.get_child(4).visible, "Right scrolls focus onto overflowed entries")
	await _action(&"ui_left")
	check(root.gui_get_focus_owner() == rail.get_child(3), "Left moves back")
	rail.free()

func _action(action: StringName) -> void:
	var event := InputEventAction.new()
	event.action = action
	event.pressed = true
	root.push_input(event)
	await settle()

func records() -> Array:
	var categories: Array[Dictionary] = [
		{"id": "favorites", "title": "Favourites", "icon": Icon},
		{"id": "masonry", "title": "Masonry", "icon": Icon},
		{"id": "empty", "title": "Timber", "icon": Icon},
	]
	var entries: Array[Dictionary] = [
		{"id": "slate", "title": "Slate", "preview": Icon, "categories": ["favorites", "masonry"]},
		{"id": "brick", "title": "Yellow brick", "preview": Icon, "category": "masonry"},
		{"id": "cobble", "title": "Cobble", "preview": Icon, "category": "masonry", "disabled": true},
		{"id": "flag", "title": "Flagstone", "preview": Icon, "category": "masonry"},
	]
	return [categories, entries]

func picker(selected := "brick") -> Control:
	var control: Control = load(UI + "arc_picker.tscn").instantiate()
	control.animate_open = false
	host.add_child(control)
	var data := records()
	control.configure(data[0], data[1], selected, {"empty": "No materials"})
	return control

func _picker_records() -> void:
	var control := picker()
	await settle()
	check(control.theme == null, "Picker selects no appearance")
	check(not control.is_open(), "The picker starts closed until opened")
	check(control.get_category_track().get_child_count() == 3, "One medallion per category")
	check(control.current_category() == "masonry", "Initial category owns the selected entry")
	var items: Array = control.get_item_track().get_children()
	check(items.map(func(b): return b.entry_id) == ["slate", "brick", "cobble", "flag"], "Item track lists the category's entries in order")
	check(items[1].button_pressed and items[1].get_node("Marker").visible, "Selected entry is pressed and marked")
	check(not items[0].get_node("Marker").visible, "Unselected entries carry no mark")
	check(items[2].disabled, "Disabled records stay visible but unavailable")
	check(items[2].get_node("Well").modulate.a < 1.0 and items[1].get_node("Well").modulate == Color.WHITE, "Unavailable previews dim")
	# Shown entries redraw when disabled changes; hidden ones settle when shown.
	control.open_at(Vector2(640, 400))
	items[1].disabled = true
	await settle()
	check(items[1].get_node("Well").modulate.a < 1.0, "Disabling later also dims the preview")
	items[1].disabled = false
	await settle()
	check(items[1].get_node("Well").modulate == Color.WHITE, "Enabling restores the preview")
	control.close()
	check(items[0].accessibility_name == "Slate" and items[0].tooltip_text == "Slate", "Entries are named from their title")
	check(items[0].theme_type_variation == &"RookframeArcItem", "Items use the item variation")
	check(control.get_category_track().get_child(0).theme_type_variation == &"RookframeArcCategory", "Categories use the category variation")
	check(items[0].get_node("Well/Preview").texture == Icon, "Item preview fills the well")
	var large := control.get_category_track().get_child(0) as Button
	large.icon = load("res://rookframe/ui/icons/character/staff.svg")
	check(large.expand_icon and large.get_combined_minimum_size().x <= 52, "Category art never grows the medallion")
	for button in items + control.get_category_track().get_children():
		var minimum: Vector2 = button.get_combined_minimum_size()
		check(minimum.x >= 44 and minimum.y >= 44, "Targets are at least 44 x 44")
	check(control.get_node("%Kicker").text == "Masonry" and control.get_node("%Title").text == "Yellow brick", "Caption names the category and selection")
	var changed := []
	control.category_changed.connect(func(id: String): changed.append(id))
	check(control.select_category("favorites") and changed == ["favorites"], "Selecting a category reports it")
	await settle()
	check(control.get_item_track().get_children().map(func(b): return b.entry_id) == ["slate"], "Entries may belong to several categories")
	check(control.get_category_track().get_child(0).button_pressed and not control.get_category_track().get_child(1).button_pressed, "Exactly one category is pressed")
	check(not control.select_category("missing"), "Unknown categories are rejected")
	control.select_category("empty")
	await settle()
	check(control.get_item_track().get_child_count() == 0 and control.get_node("%Title").text == "No materials", "Empty categories say so in the caption")
	control.get_category_track().spacing = 400.0
	control.select_category("masonry")
	await settle()
	check(control.get_category_track().get_child(1).visible, "A category selected from code scrolls onto the rail")
	control.free()

func _picker_choice() -> void:
	var control := picker()
	control.open_at(Vector2(640, 400))
	await settle()
	var chosen := []
	var highlights := []
	control.choose_requested.connect(func(entry: Dictionary): chosen.append(entry))
	control.highlight_changed.connect(func(entry: Dictionary): highlights.append(entry.get("id", "")))
	var flag: Button = control.get_item_track().get_child(3)
	flag.grab_focus()
	check(highlights.back() == "flag" and control.get_node("%Title").text == "Flagstone", "Focus highlights and captions the entry")
	flag.pressed.emit()
	flag.button_pressed = true
	check(chosen.size() == 1 and chosen[0].id == "flag" and chosen[0].preview == Icon, "Choosing reports the full record")
	check(control.selected_id() == "flag", "Choosing selects the entry")
	check(flag.get_node("Marker").visible and not control.get_item_track().get_child(1).get_node("Marker").visible, "The mark follows the selection")
	control.set_selected("slate")
	check(control.get_item_track().get_child(0).button_pressed and not flag.button_pressed and chosen.size() == 1, "Hosts can set the selection without a choice")
	flag.grab_focus()
	control.select_category("empty")
	check(control.get_node("%Title").text == "No materials", "A removed item's highlight leaves the caption")
	control.free()

func _picker_keyboard() -> void:
	var control := picker()
	control.open_at(Vector2(640, 400))
	await settle()
	var items: Container = control.get_item_track()
	var categories: Container = control.get_category_track()
	check(root.gui_get_focus_owner() == items.get_child(1), "Opening focuses the selected entry")
	await _action(&"ui_down")
	check(root.gui_get_focus_owner() == categories.get_child(1), "Down moves to the current category")
	await _action(&"ui_left")
	check(root.gui_get_focus_owner() == categories.get_child(0) and control.current_category() == "favorites", "Keyboard focus selects categories")
	await _action(&"ui_up")
	check(root.gui_get_focus_owner() == control.get_item_track().get_child(0), "Up moves out to the first available entry")
	control.free()

func _picker_dismissal() -> void:
	var control := picker()
	var cancelled := []
	control.cancel_requested.connect(func(): cancelled.append(true))
	control.open_at(Vector2(640, 400))
	await settle()
	check(control.is_open(), "Opening shows the picker")
	await _action(&"ui_cancel")
	check(not control.is_open() and cancelled.size() == 1, "Cancel closes and reports")
	control.open_at(Vector2(640, 400))
	await settle()
	var inside: Control = control.get_item_track().get_child(0)
	_click(inside.get_global_rect().get_center())
	await settle()
	check(control.is_open(), "Presses on entries are not outside clicks")
	_click(Vector2(20, 20))
	await settle()
	check(not control.is_open() and cancelled.size() == 2, "Outside presses close and report")
	control.close_on_outside_click = false
	control.open_at(Vector2(640, 400))
	await settle()
	_click(Vector2(20, 20))
	await settle()
	check(control.is_open(), "Outside closing can be turned off")
	control.animate_open = true
	control.close()
	control.open_at(Vector2(640, 400))
	check(control.get_item_track().reveal < 1.0, "Opening animates when motion is allowed")
	control.close()
	check(control.get_item_track().reveal == 1.0 and control.modulate.a == 1.0, "Closing settles presentation")
	control.reduced_motion = true
	control.open_at(Vector2(640, 400))
	check(control.get_item_track().reveal == 1.0, "Reduced motion opens settled")
	control.free()

func _click(at: Vector2) -> void:
	var press := InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.pressed = true
	press.position = at
	press.global_position = at
	root.push_input(press, true)
	var release := press.duplicate()
	release.pressed = false
	root.push_input(release, true)

func _picker_fit() -> void:
	var control := picker()
	var bounds := host.get_viewport_rect().grow(-control.viewport_margin + 1.0)
	var far := bounds.end
	for at in [Vector2(far.x * 0.5, 40), Vector2(far.x - 20, far.y * 0.5), far - Vector2(20, 20), Vector2(20, far.y - 20)]:
		control.open_at(at)
		await settle()
		for button in control.get_item_track().get_placed_entries() + control.get_category_track().get_placed_entries():
			check(bounds.encloses(button.get_global_rect()), "Entries stay on screen when opened at %s" % at)
		control.close()
	var stage := Control.new()
	stage.clip_contents = true
	stage.position = Vector2(200, 150)
	stage.size = Vector2(700, 520)
	host.add_child(stage)
	control.reparent(stage, false)
	control.open_at(Vector2(690, 10))
	await settle()
	var clip := stage.get_global_rect().grow(-control.viewport_margin + 1.0)
	for button in control.get_item_track().get_placed_entries() + control.get_category_track().get_placed_entries():
		check(clip.encloses(button.get_global_rect()), "Entries stay inside a clipping ancestor")
	control.close()
	control.reparent(host, false)
	stage.free()
	control.fit_to_viewport = false
	control.open_at(Vector2(640, 40))
	await settle()
	check(control.position == Vector2(640, 40) and control.get_item_track().start_angle == 190.0, "Fitting can be turned off")
	control.free()
