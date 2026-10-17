extends SceneTree
const LEDGER = preload("res://rookframe/ui/themes/silkbound-ledger/theme.tres")
const BUTTON = preload("res://rookframe/ui/components/actions/button.tscn")
const PANEL = preload("res://rookframe/ui/components/surfaces/action_panel/action_panel.tscn")
const LEAF = preload("res://rookframe/ui/components/surfaces/hinged_leaf/hinged_leaf.tscn")
const COLLECTION = preload("res://rookframe/ui/components/data/collection.tscn")
var failures: Array[String] = []
func _initialize() -> void:
	verify.call_deferred()
func check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
		push_error(message)
func settle() -> void:
	for frame in 8: await process_frame
func verify() -> void:
	root.size = Vector2i(1024, 768)
	var host := Control.new()
	host.size = Vector2(1024, 768)
	host.theme = LEDGER
	root.add_child(host)
	var panel = PANEL.instantiate()
	panel.reduced_motion = true
	host.add_child(panel)
	var action = BUTTON.instantiate()
	action.text = "Retained action"
	action.accessibility_name = "Retained action"
	action.toggle_mode = true
	action.button_pressed = true
	var calls := [0]
	action.pressed.connect(func(): calls[0] += 1)
	panel.get_footer_slot().add_child(action)
	await settle()
	action.grab_focus()
	for appearance in [load("res://rookframe/ui/themes/fantasy/theme.tres"), load("res://rookframe/ui/themes/cyberpunk/theme.tres"), LEDGER, null, LEDGER]:
		host.theme = appearance
		await settle()
		check(panel.get_footer_slot().get_child(0) == action, "Caller content identity")
		check(action.has_focus(), "Native focus retained")
		check(action.button_pressed and action.text == "Retained action", "Button state retained")
		check(action.accessibility_name == "Retained action", "Accessible name retained")
		action.pressed.emit()
	check(calls[0] == 5, "Original signal connections retained")
	var collection = COLLECTION.instantiate()
	collection.size = Vector2(500, 250)
	collection.position = Vector2(500, 300)
	collection.reduced_motion = true
	host.add_child(collection)
	var entries: Array[Dictionary] = []
	for index in 12: entries.append({"id": str(index), "title": "Item %d" % index, "subtitle": "Retained content", "action": "Equip"})
	collection.configure(entries, "7", "Inventory", "12")
	await settle()
	var rows: Node = collection.get_node("Content/Area/Rows")
	var retained := rows.get_child(7)
	collection.focus_entry("7")
	host.theme = load("res://rookframe/ui/themes/fantasy/theme.tres")
	await settle()
	host.theme = LEDGER
	await settle()
	check(rows.get_child(7) == retained, "Generated rows keep identity")
	check(collection.focus_entry("7"), "Retained row remains focusable")
	var leaf = LEAF.instantiate()
	leaf.size = Vector2(360, 240)
	leaf.theme = LEDGER
	leaf.reduced_motion = true
	host.add_child(leaf)
	leaf.set_open(true, false)
	await settle()
	check(leaf.theme == LEDGER, "Explicit canonical Theme remains Inspector resource")
	check(leaf.get_content().theme == LEDGER, "SubViewport inherits selected Theme")
	check(leaf.get_node("Bindings/Left").material != null, "Binding shader supplied")
	var first := Button.new()
	var focused := Button.new()
	leaf.get_content().add_child(first)
	leaf.get_content().add_child(focused)
	focused.grab_focus()
	var settlements := [0]
	leaf.settled.connect(func(_open): settlements[0] += 1)
	var other = LEAF.instantiate()
	other.reduced_motion = true
	host.add_child(other)
	check(leaf.get_node("Bindings/Left").material != other.get_node("Bindings/Left").material, "Animated shader resources are per instance")
	leaf.theme = null
	host.theme = null
	await settle()
	check(leaf.is_open and not leaf.animating, "Open state retained when presentation changes")
	check(leaf.get_node("Bindings/Left").material == null, "Removed theme restores binding material")
	check(focused.has_focus(), "SubViewport focus retained")
	check(settlements[0] == 0, "Theme changes do not emit behavioral settlement signals")
	var local_theme := Theme.new()
	leaf.get_content().theme = local_theme
	host.theme = LEDGER
	await settle()
	check(leaf.get_content().theme == local_theme, "Explicit content Theme remains a local scope")
	host.free()
	await process_frame
	print("THEME STATE: %d failures" % failures.size())
	quit(0 if failures.is_empty() else 1)
