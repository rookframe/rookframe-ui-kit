extends SceneTree
## HUD components keep the variation, layout and forwarding contracts consumers build on.
const UI := "res://rookframe/ui/components/"
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
	await _stacked_button()
	await _hud_profile()
	await _hud_overflow()
	await _hud_empty_slots()
	await _identity_plate()
	await _vital_meter()
	await _emblem()
	await _context_scope()
	for failure in failures: push_error(failure)
	print("HUD_COMPONENTS: %d assertions; %d failures" % [assertions, failures.size()])
	quit(0 if failures.is_empty() else 1)

func stacked(text: String = "Abilities") -> Button:
	var control: Button = load(UI + "actions/button.tscn").instantiate()
	control.layout = Action.Layout.STACKED
	control.text = text
	control.icon = Icon
	return control

func _stacked_button() -> void:
	for variant in [Action.Variant.SECONDARY, Action.Variant.PRIMARY, Action.Variant.DESTRUCTIVE, Action.Variant.EMBLEM]:
		for compact in [false, true]:
			var sample := stacked()
			sample.variant = variant
			sample.accessibility_name = "Abilities"
			sample.compact = compact
			host.add_child(sample)
			await settle()
			var expected := String(Action.THEME_TYPES[variant]) + "__stacked" + ("__compact" if compact else "")
			check(sample.theme_type_variation == StringName(expected), "Stacked Button resolves " + expected)
			var minimum: Vector2 = sample.get_combined_minimum_size()
			check(minimum.x >= 44 and minimum.y >= 44, "Stacked target is at least 44 x 44")
			sample.free()
	var control := stacked("Companions")
	control.vertical_icon_alignment = VERTICAL_ALIGNMENT_BOTTOM
	control.layout = Action.Layout.INLINE
	host.add_child(control)
	await settle()
	control.layout = Action.Layout.STACKED
	check(control.icon_alignment == HORIZONTAL_ALIGNMENT_CENTER and control.vertical_icon_alignment == VERTICAL_ALIGNMENT_TOP, "Stacked places the icon above the label")
	check(control.autowrap_mode == TextServer.AUTOWRAP_WORD_SMART and control.text_overrun_behavior == TextServer.OVERRUN_NO_TRIMMING, "Stacked labels wrap and are never trimmed")
	check(control.accessibility_name.is_empty(), "Native Button keeps naming itself from its label")
	var word := control.get_theme_font("font").get_string_size("Companions", HORIZONTAL_ALIGNMENT_LEFT, -1, control.get_theme_font_size("font_size")).x
	check(control.get_combined_minimum_size().x >= word, "Wrapping keeps the widest word whole")
	control.text = "Companions and extraordinarily long hirelings"
	await settle()
	word = control.get_theme_font("font").get_string_size("extraordinarily", HORIZONTAL_ALIGNMENT_LEFT, -1, control.get_theme_font_size("font_size")).x
	check(control.get_combined_minimum_size().x >= word, "Label edits refit the widest word")
	var packed := PackedScene.new()
	check(packed.pack(control) == OK, "Stacked Button can be saved")
	var stored := []
	for index in packed.get_state().get_node_property_count(0):
		stored.append(packed.get_state().get_node_property_name(0, index))
	check(&"layout" in stored and not &"vertical_icon_alignment" in stored and not &"autowrap_mode" in stored, "Scenes store the layout, not the values it controls")
	var restored: Button = packed.instantiate()
	host.add_child(restored)
	await settle()
	check(restored.vertical_icon_alignment == VERTICAL_ALIGNMENT_TOP, "A restored stacked Button arranges itself again")
	restored.free()
	control.layout = Action.Layout.INLINE
	check(control.vertical_icon_alignment == VERTICAL_ALIGNMENT_BOTTOM and control.autowrap_mode == TextServer.AUTOWRAP_OFF, "Inline restores the caller's native values")
	check(control.theme_type_variation == &"components_button", "Inline drops the stacked suffix")
	control.custom_minimum_size = Vector2(320, 96)
	control.layout = Action.Layout.STACKED
	control.compact = true
	await settle()
	check(control.custom_minimum_size == Vector2(320, 96), "Stacked keeps a larger caller minimum")
	var theme := Theme.new()
	theme.set_type_variation(&"components_button__stacked", &"components_button")
	theme.set_type_variation(&"components_button__stacked__compact", &"components_button__stacked")
	theme.set_constant("minimum_height", &"components_button", 64)
	control.custom_minimum_size = Vector2.ZERO
	host.theme = theme
	await settle()
	check(control.custom_minimum_size.y == 64, "A theme's declared base chain resolves suffixed names")
	# A raised pressed state wraps inside wider margins than the normal state.
	var raised := StyleBoxEmpty.new()
	raised.content_margin_left = 30
	raised.content_margin_right = 30
	theme.set_stylebox("pressed", &"components_button", raised)
	control.text = "Companions"
	await settle()
	word = control.get_theme_font("font").get_string_size("Companions", HORIZONTAL_ALIGNMENT_LEFT, -1, control.get_theme_font_size("font_size")).x
	check(control.custom_minimum_size.x >= word + 60, "Wrapping reserves the widest state margins")
	host.theme = null
	control.free()

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
		var tile := stacked("Category %d" % (index + 1))
		tile.toggle_mode = true
		tile.button_group = group
		slot.add_child(tile)
		tiles.append(tile)
	var plain := stacked("Plain")
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
	var category := stacked()
	bar.get_category_slot().add_child(category)
	var choice := stacked("Choice")
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

func _context_scope() -> void:
	# A theme styles tiles by their container: its presentation template scopes a
	# profile Theme to the HudBar category slot through the kit's binding.
	var profile := Theme.new()
	profile.set_constant("minimum_height", &"components_button__stacked", 96)
	var source := GDScript.new()
	source.source_code = "@tool\nextends Theme\nvar presentations := {}\n"
	source.reload()
	var theme: Theme = source.new()
	# Godot resolves a variation only when a theme declares its base; the profile overrides items.
	theme.set_type_variation(&"components_button__stacked", &"Button")
	var template_root := VBoxContainer.new()
	template_root.name = "HudBar"
	var parent: Node = template_root
	for name in ["Bar", "Row", "CategorySlot"]:
		var node := HBoxContainer.new()
		node.name = name
		parent.add_child(node)
		node.owner = template_root
		parent = node
	parent.theme = profile
	var template := PackedScene.new()
	template.pack(template_root)
	template_root.free()
	theme.presentations[UI + "layout/hud_bar.tscn"] = template
	var pair := await _bar(1920)
	var bar = pair[1]
	var category := stacked()
	var leading := stacked("Roll")
	bar.get_category_slot().add_child(category)
	bar.get_leading_slot().add_child(leading)
	pair[0].theme = theme
	await settle()
	check(category.custom_minimum_size.y == 96 and leading.custom_minimum_size.y == 52, "A theme scopes tile appearance to the bar slot")
	pair[0].theme = null
	await settle()
	check(category.custom_minimum_size.y == 52 and bar.get_category_slot().theme == null, "Removing the theme restores the unthemed slot")
	pair[0].free()
