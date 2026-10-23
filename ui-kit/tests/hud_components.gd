extends SceneTree
## HUD components keep the variation, layout and forwarding contracts consumers build on.
const UI := "res://rookframe/ui/components/"
const Tile = preload("res://rookframe/ui/components/actions/icon_tile.gd")
const Meter = preload("res://rookframe/ui/components/data/vital_meter.gd")
const Action = preload("res://rookframe/ui/components/actions/button.gd")
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

func mount(path: String, parent: Node = host) -> Node:
	var control = load(UI + path).instantiate()
	parent.add_child(control)
	return control

func settle() -> void:
	for frame in 3:
		await process_frame

func _run() -> void:
	root.gui_embed_subwindows = true
	root.size = Vector2i(1920, 1080)
	host = Control.new()
	root.add_child(host)
	host.size = Vector2(1920, 1080)
	await _icon_tile()
	await _hud_profile()
	await _hud_overflow()
	await _hud_empty_slots()
	await _identity_plate()
	await _vital_meter()
	await _emblem()
	for failure in failures: push_error(failure)
	print("HUD_COMPONENTS: %d assertions; %d failures" % [assertions, failures.size()])
	quit(0 if failures.is_empty() else 1)

func _icon_tile() -> void:
	for usage in [Tile.Usage.CATEGORY, Tile.Usage.TOOL, Tile.Usage.CHOICE]:
		for compact in [false, true]:
			var tile = mount("actions/icon_tile.tscn")
			tile.usage = usage
			tile.compact = compact
			tile.text = "Abilities"
			tile.icon = Icon
			await settle()
			var expected := String(Tile.THEME_TYPES[usage]) + ("__compact" if compact else "")
			check(tile.theme_type_variation == StringName(expected), "IconTile resolves " + expected)
			var minimum: Vector2 = tile.get_combined_minimum_size()
			check(minimum.x >= 44 and minimum.y >= 44, "IconTile target is at least 44 x 44")
			check(tile.accessibility_name == "Abilities", "IconTile mirrors its label for assistive technology")
			check(tile.button_group == null and not tile.toggle_mode, "IconTile leaves selection to the caller")
			tile.free()
	var large = mount("actions/icon_tile.tscn")
	large.custom_minimum_size = Vector2(120, 96)
	large.compact = true
	large.usage = Tile.Usage.TOOL
	await settle()
	check(large.custom_minimum_size == Vector2(120, 96), "IconTile keeps a larger caller minimum")
	large.free()

func _bar(width: float) -> Array:
	var parent := Control.new()
	parent.size = Vector2(width, 400)
	host.add_child(parent)
	var bar = mount("layout/hud_bar.tscn", parent)
	await settle()
	return [parent, bar]

func _hud_profile() -> void:
	var expected := {1920.0: [&"wide", &"RookframeHudBar"], 1024.0: [&"medium", &"RookframeHudBar__medium"], 844.0: [&"compact", &"RookframeHudBar__compact"]}
	for width in expected:
		var pair := await _bar(width)
		var bar = pair[1]
		check(bar.get_profile() == expected[width][0], "HudBar profile at %d is %s" % [width, expected[width][0]])
		check(bar.get_node("Bar").theme_type_variation == expected[width][1], "HudBar variation at %d" % width)
		check(String(bar.get_node("AttachedPanel").theme_type_variation).begins_with("RookframeHudAttached"), "Attached panel follows the profile")
		pair[0].free()
	var pair := await _bar(1920)
	var profiles := []
	pair[1].layout_profile_changed.connect(func(profile): profiles.append(profile))
	pair[0].size.x = 844
	await settle()
	pair[0].size.x = 860
	await settle()
	check(profiles == [&"compact"], "Profile signal fires only on change")
	pair[0].free()

func _hud_overflow() -> void:
	var pair := await _bar(1920)
	var parent: Control = pair[0]
	var bar = pair[1]
	bar.compact_category_limit = 4
	var slot: Container = bar.get_category_slot()
	var group: ButtonGroup = load(UI + "forms/selection_group.tres").duplicate()
	group.allow_unpress = true
	var tiles: Array[Button] = []
	for index in 7:
		var tile = load(UI + "actions/icon_tile.tscn").instantiate()
		tile.text = "Category %d" % (index + 1)
		tile.icon = Icon
		tile.toggle_mode = true
		tile.button_group = group
		slot.add_child(tile)
		tiles.append(tile)
	var plain = load(UI + "actions/icon_tile.tscn").instantiate()
	plain.text = "Plain"
	slot.add_child(plain)
	tiles[2].visible = false
	await settle()
	check(not bar.get_node("%More").visible, "Wide profile shows every tile")
	parent.size.x = 844
	await settle()
	var visible := []
	for tile in tiles: visible.append(tile.visible)
	check(visible == [true, true, false, true, true, false, false] and not plain.visible, "Compact hides tiles beyond the limit, skipping caller-hidden ones")
	check(bar.get_node("%More").visible and bar.get_node("%More").text == "More", "More appears with overflow")
	check(tiles[0].compact, "Compact propagates to slot children")
	var opened := []
	bar.overflow_opened.connect(func(): opened.append(true))
	tiles[0].button_pressed = true
	bar.get_node("%More").pressed.emit()
	await settle()
	var popover = bar.get_node("Overflow")
	var rows: Array = popover.get_content_slot().get_children()
	check(popover.is_open() and opened.size() == 1, "More opens the overflow popover")
	check(rows.size() == 3 and rows[0].title == "Category 6" and rows[2].title == "Plain", "One row per overflowed tile")
	var toggles := []
	tiles[5].toggled.connect(func(on): toggles.append(on))
	rows[0].pressed.emit()
	await settle()
	check(not popover.is_open(), "Activating a row closes the popover")
	check(tiles[5].button_pressed and toggles == [true] and not tiles[0].button_pressed, "Forwarded toggle uses the native ButtonGroup")
	check(bar.get_node("%More").has_focus(), "Focus returns to More")
	var presses := []
	plain.pressed.connect(func(): presses.append(true))
	bar.get_node("%More").pressed.emit()
	await settle()
	popover.get_content_slot().get_child(2).pressed.emit()
	await settle()
	check(presses.size() == 1, "Forwarded plain row emits the original pressed")
	tiles[6].disabled = true
	bar.get_node("%More").pressed.emit()
	await settle()
	check(popover.get_content_slot().get_child(1).disabled, "Disabled tile gives a disabled row")
	bar.close_overflow()
	parent.size.x = 1920
	await settle()
	visible.clear()
	for tile in tiles: visible.append(tile.visible)
	check(visible == [true, true, false, true, true, true, true] and plain.visible, "Wide restores bar-hidden tiles; caller-hidden tile stays hidden")
	var order := true
	for index in tiles.size():
		order = order and tiles[index].get_parent() == slot and tiles[index].get_index() == index
	check(order and plain.get_index() == 7, "No caller node changes parent or index")
	check(not tiles[0].compact, "Leaving compact restores normal density")
	parent.free()

func _hud_empty_slots() -> void:
	var pair := await _bar(1920)
	var bar = pair[1]
	for path in ["%LeadingSlot", "%IdentitySlot", "%CategorySlot", "%TrailingSlot", "Bar/Row/Divider", "AttachedPanel"]:
		check(not bar.get_node(path).visible, "Empty HUD part is hidden: " + path)
	var identity = load(UI + "data/identity_plate.tscn").instantiate()
	bar.get_identity_slot().add_child(identity)
	var tile = load(UI + "actions/icon_tile.tscn").instantiate()
	bar.get_category_slot().add_child(tile)
	var choice = load(UI + "actions/icon_tile.tscn").instantiate()
	bar.get_attached_slot().add_child(choice)
	await settle()
	check(bar.get_identity_slot().visible and bar.get_category_slot().visible, "Filled slots appear")
	check(bar.get_node("Bar/Row/Divider").visible and bar.get_node("AttachedPanel").visible, "Divider and attached panel appear with content")
	check(not bar.get_leading_slot().visible and not bar.get_trailing_slot().visible, "Unfilled slots stay hidden")
	choice.visible = false
	await settle()
	check(not bar.get_node("AttachedPanel").visible, "Hiding attached content hides the panel")
	pair[0].free()

func _identity_plate() -> void:
	var plate = mount("data/identity_plate.tscn")
	plate.title = "Wanderer"
	plate.detail = "Pilgrim"
	await settle()
	var ignored := true
	var pending: Array[Node] = plate.get_children()
	while not pending.is_empty():
		var node: Node = pending.pop_back()
		if node is Control:
			ignored = ignored and node.mouse_filter == Control.MOUSE_FILTER_IGNORE
		pending.append_array(node.get_children())
	check(ignored, "Every IdentityPlate descendant ignores the mouse")
	check(plate.accessibility_name == "Wanderer, Pilgrim", "Accessibility name combines title and detail")
	check(not plate.get_vital_slot().visible, "Empty vital slot is hidden")
	check(plate.text.is_empty() and plate.icon == null, "Button text and icon stay empty")
	var minimum: Vector2 = plate.get_combined_minimum_size()
	check(minimum.x >= 44 and minimum.y >= 44, "IdentityPlate target is at least 44 x 44")
	var meter = load(UI + "data/vital_meter.tscn").instantiate()
	plate.get_vital_slot().add_child(meter)
	await settle()
	check(plate.get_vital_slot().visible, "Vital slot appears with content")
	plate.compact = true
	check(plate.theme_type_variation == &"RookframeHudIdentity__compact", "Compact identity variation")
	plate.detail = ""
	check(plate.accessibility_name == "Wanderer" and not plate.get_node("Content/Row/Copy/Detail").visible, "Empty detail is hidden")
	plate.free()

func _vital_meter() -> void:
	var meter = mount("data/vital_meter.tscn")
	meter.value = 7
	meter.max_value = 12
	await settle()
	check(meter.get_node("Header/Value").text == "7/12", "Default value text formats without trailing zeros")
	check(meter.accessibility_name == "HP 7/12", "Accessibility name carries caption and value")
	for level in [Meter.Level.STEADY, Meter.Level.WOUNDED, Meter.Level.CRITICAL, Meter.Level.DEPLETED]:
		meter.level = level
		check(meter.get_node("Track").theme_type_variation == Meter.TRACK_TYPES[level], "Level sets track variation " + String(Meter.TRACK_TYPES[level]))
	meter.max_value = 0.0
	check(meter.get_node("Track").max_value > 0.0, "Track maximum stays positive")
	meter.show_track = false
	check(not meter.get_node("Track").visible, "show_track hides the track")
	meter.free()

func _emblem() -> void:
	check(Action.Variant.SECONDARY == 0 and Action.Variant.PRIMARY == 1 and Action.Variant.DESTRUCTIVE == 2 and Action.Variant.EMBLEM == 3, "Existing Button variant integers are unchanged")
	var button = mount("actions/button.tscn")
	button.variant = Action.Variant.EMBLEM
	button.icon = Icon
	button.accessibility_name = "Roll dice"
	await settle()
	check(button.theme_type_variation == &"components_button_emblem", "Emblem resolves its variation")
	check(button.icon_alignment == HORIZONTAL_ALIGNMENT_CENTER, "Emblem centres its icon")
	button.compact = true
	check(button.theme_type_variation == &"components_button_emblem__compact", "Compact emblem variation")
	button.free()
