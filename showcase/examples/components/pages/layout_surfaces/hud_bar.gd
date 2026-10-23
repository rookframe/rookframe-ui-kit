extends RefCounted
## HUD compositions consumers build: character, creature and builder tools.

const Demo = preload("res://examples/components/pages/layout_surfaces/demo.gd")
const Action = preload("res://rookframe/ui/components/actions/button.gd")
const Meter = preload("res://rookframe/ui/components/data/vital_meter.gd")
const Choice = preload("res://rookframe/ui/components/forms/choice.gd")
const ICONS := "res://rookframe/ui/icons/"
const CHARACTER := [["Abilities", "bolt"], ["Attacks", "swords"], ["Powers", "sigil"], ["Items", "pack"], ["Features", "list"], ["Companions", "people"], ["Recovery", "shield"]]
const CREATURE := [["Attacks", "swords"], ["Special", "sigil"], ["Checks", "dice"], ["Scene", "world"]]

static func build(page) -> void:
	_character(page)
	_creature(page)
	_builder(page)

static func _report(status: Label, copy: String) -> void:
	status.text = copy

static func _bar(page, body: Node, limit: int) -> Node:
	# Like a HUD layer, a plain Control stage follows the page width rather than the bar's.
	var stage := Control.new()
	stage.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_child(stage)
	var bar = Demo.component(page, "components/layout/hud_bar.tscn", stage, {"compact_category_limit": limit})
	bar.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	bar.grow_horizontal = Control.GROW_DIRECTION_BOTH
	bar.grow_vertical = Control.GROW_DIRECTION_BEGIN
	var fit := func(): stage.custom_minimum_size.y = bar.get_combined_minimum_size().y
	bar.minimum_size_changed.connect(fit)
	fit.call()
	var status = page.note(body, "No HUD signal yet.")
	bar.layout_profile_changed.connect(func(profile: StringName): _report(status, "Profile: " + profile))
	bar.set_meta(&"status", status)
	return bar

static func _identity(page, bar, title: String, detail: String, initials: String) -> Node:
	var plate = Demo.component(page, "components/data/identity_plate.tscn", bar.get_identity_slot(), {"title": title, "detail": detail, "initials": initials})
	plate.pressed.connect(func(): _report(bar.get_meta(&"status"), "pressed: " + title + " (open record)"))
	return plate

# HUD tiles are stacked Buttons; the bar slot, not the Button, gives them context.
static func _tile(page, parent: Node, entry: Array, properties: Dictionary = {}) -> Button:
	properties.merge({"layout": Action.Layout.STACKED, "text": entry[0], "icon": load(ICONS + entry[1] + ".svg")})
	return Demo.component(page, "components/actions/button.tscn", parent, properties)

static func _tiles(page, bar, entries: Array, group: ButtonGroup) -> Array:
	var status: Label = bar.get_meta(&"status")
	var tiles := []
	for entry in entries:
		var tile = _tile(page, bar.get_category_slot(), entry, {"toggle_mode": true, "button_group": group})
		tile.toggled.connect(func(on: bool): _report(status, "toggled(%s): %s" % [on, entry[0]]))
		tiles.append(tile)
	return tiles

static func _character(page) -> void:
	var body = page.section("Character HUD", "Emblem, identity with a vital, and seven category tiles. In the compact profile four tiles stay and the rest move to More; choosing one there toggles the original tile.")
	var bar = _bar(page, body, 4)
	var status: Label = bar.get_meta(&"status")
	var emblem = Demo.component(page, "components/actions/button.tscn", bar.get_leading_slot(), {
		"variant": Action.Variant.EMBLEM, "icon": load(ICONS + "dice.svg"),
		"accessibility_name": "Roll dice", "tooltip_text": "Roll dice",
	})
	emblem.pressed.connect(func(): _report(status, "pressed: Roll dice"))
	var plate = _identity(page, bar, "Wanderer", "Pilgrim of the coast", "WA")
	Demo.component(page, "components/data/vital_meter.tscn", plate.get_vital_slot(), {"caption": "HP", "value": 7.0, "max_value": 12.0, "level": Meter.Level.WOUNDED})
	var group: ButtonGroup = load("res://rookframe/ui/components/forms/selection_group.tres").duplicate()
	group.allow_unpress = true
	var list = _category_list(page)
	var state := {"tile": null}
	for tile in _tiles(page, bar, CHARACTER, group):
		tile.toggled.connect(func(on: bool):
			if on:
				list.get_meta(&"header").title = tile.text
				# An overflowed tile is hidden; its list anchors to the bar instead.
				list.open_for(tile if tile.is_visible_in_tree() else bar)
				state.tile = tile
			elif list.is_open() and state.tile == tile:
				list.close()
		)
	list.closed.connect(func(_reason: StringName):
		var tile = state.tile
		state.tile = null
		if is_instance_valid(tile) and tile.button_pressed:
			tile.button_pressed = false
	)

static func _category_list(page) -> Node:
	var popover = page.scene(Demo.CORE + "components/overlays/popover.tscn", page, {"theme": page.preview_theme})
	var content: Container = popover.get_content_slot()
	var header = Demo.component(page, "components/layout/task_header.tscn", content, {"title": "Category"})
	var show_all: CheckBox = load(Demo.CORE + "components/forms/checkbox.tscn").instantiate()
	show_all.text = "Show all"
	header.get_actions_slot().add_child(show_all)
	page.button(header.get_actions_slot(), "Close", func(): popover.close())
	var host := Demo.region(content, 220)
	var pages = load(Demo.CORE + "components/data/paginated_content.tscn").instantiate()
	pages.reduced_motion = true
	var column := VBoxContainer.new()
	pages.get_node("Area").add_child(column)
	for index in 4:
		var row = Demo.component(page, "components/data/structured_row.tscn", column, {"title": "Entry %d" % (index + 1), "detail": "A short summary of this entry.", "value_text": "d%d" % [4, 6, 8, 10][index]})
		Demo.component(page, "components/data/action_row.tscn", row.get_action_slot(), {"title": "Use", "description": "", "action_label": "", "custom_minimum_size": Vector2(88, 44), "size_flags_horizontal": Control.SIZE_SHRINK_END, "size_flags_vertical": Control.SIZE_SHRINK_CENTER})
		Demo.component(page, "components/forms/favorite_toggle.tscn", row.get_action_slot(), {"accessibility_name": "Favorite: Entry %d" % (index + 1), "tooltip_text": "Favorite", "size_flags_vertical": Control.SIZE_SHRINK_CENTER})
	host.add_child(pages)
	pages.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	popover.set_meta(&"header", header)
	return popover

static func _creature(page) -> void:
	var body = page.section("Creature HUD", "Identity without a vital, four category tiles that never overflow, and a trailing HP action.")
	var bar = _bar(page, body, -1)
	var status: Label = bar.get_meta(&"status")
	_identity(page, bar, "Grave Hound", "Beast", "GH")
	var group: ButtonGroup = load("res://rookframe/ui/components/forms/selection_group.tres").duplicate()
	group.allow_unpress = true
	_tiles(page, bar, CREATURE, group)
	var health = Demo.component(page, "components/data/action_row.tscn", bar.get_trailing_slot(), {"title": "HP", "description": "", "action_label": "9", "custom_minimum_size": Vector2(112, 58)})
	health.pressed.connect(func(): _report(status, "pressed: HP"))

static func _builder(page) -> void:
	var body = page.section("Builder tools", "Tool tiles, a mode switch and an attached choice panel that appears while Shape or Texture is active.")
	var bar = _bar(page, body, -1)
	var status: Label = bar.get_meta(&"status")
	var tools: Array = []
	var tunnels: Array = []
	var group: ButtonGroup = load("res://rookframe/ui/components/forms/selection_group.tres").duplicate()
	for entry in [["Select", "crosshair", true], ["Add", "add", true], ["Connect", "link", true], ["Undo", "retry", false], ["Done", "check", false]]:
		tools.append(_tool(page, bar, entry, group if entry[2] else null))
	group.get_buttons()[0].button_pressed = true
	var mode := ButtonGroup.new()
	mode.allow_unpress = true
	for entry in [["Back", "back", false], ["Shape", "region-polygon", true], ["Texture", "layers", true], ["Undo", "retry", false], ["Done", "check", false]]:
		var tile = _tool(page, bar, entry, mode if entry[2] else null)
		tile.visible = false
		tunnels.append(tile)
	var shapes = _choices(page, bar, [["Round", "region-circle"], ["Square", "region-rectangle"], ["Free", "region-free-form"]])
	var surfaces = _choices(page, bar, [["Stone", "world"], ["Earth", "compass"], ["Ice", "ruler"]])
	var swatch = Demo.component(page, "components/forms/choice.tscn", bar.get_attached_slot(), {"variant": Choice.Variant.CARD, "title": "Granite", "description": "Grey stone", "leading_icon": load(ICONS + "layers.svg"), "compact": true})
	var attached := [shapes, surfaces, swatch]
	var show_options := func():
		shapes.visible = tunnels[1].button_pressed
		surfaces.visible = tunnels[2].button_pressed
		swatch.visible = tunnels[2].button_pressed
	for item in attached:
		item.visible = false
	tunnels[1].toggled.connect(func(_on): show_options.call())
	tunnels[2].toggled.connect(func(_on): show_options.call())
	var switch_mode := func(to_tunnels: bool):
		for tile in tools: tile.visible = not to_tunnels
		for tile in tunnels: tile.visible = to_tunnels
		if not to_tunnels and mode.get_pressed_button() != null:
			mode.get_pressed_button().button_pressed = false
		_report(status, "mode: " + ("Tunnels" if to_tunnels else "Tools"))
	page.button(page.flow(body), "Tunnels mode", func(): switch_mode.call(true))
	tunnels[0].pressed.connect(func(): switch_mode.call(false))

static func _tool(page, bar, entry: Array, group: ButtonGroup) -> Button:
	var status: Label = bar.get_meta(&"status")
	var tile = _tile(page, bar.get_category_slot(), entry, {"toggle_mode": entry[2]})
	if group != null:
		tile.button_group = group
		tile.toggled.connect(func(on: bool): _report(status, "toggled(%s): %s" % [on, entry[0]]))
	else:
		tile.pressed.connect(func(): _report(status, "pressed: " + entry[0]))
	return tile

static func _choices(page, bar, entries: Array) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	bar.get_attached_slot().add_child(row)
	var group := ButtonGroup.new()
	for entry in entries:
		_tile(page, row, entry, {"toggle_mode": true, "button_group": group})
	group.get_buttons()[0].button_pressed = true
	return row
