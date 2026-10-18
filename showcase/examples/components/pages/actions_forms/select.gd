extends RefCounted
const Demo = preload("res://examples/components/pages/actions_forms/support.gd")

static func build(page) -> void:
	var main = page.section("Native selection", "Open the menu and type to search its items. Selection callbacks resolve a stable record ID.")
	var select := preload("res://rookframe/ui/components/forms/select.tscn").instantiate() as OptionButton
	select.custom_minimum_size.y = 44
	select.accessibility_name = "Travel destination"
	select.add_item("Northern gate", 11)
	select.add_item("Silver harbour", 24)
	select.add_item("Closed mountain pass", 83)
	select.set_item_disabled(2, true)
	select.get_popup().allow_search = true
	main.add_child(select)
	var status = page.note(main, "Destination ID: 11")
	select.item_selected.connect(func(index: int): status.text = "Destination ID: %d · %s" % [select.get_item_id(index), select.get_item_text(index)])
	page.button(page.flow(main), "Focus select", select.grab_focus)
	var other = page.section("Empty and disabled", "An empty source has no selected index; a disabled select retains its current value.")
	var empty := preload("res://rookframe/ui/components/forms/select.tscn").instantiate() as OptionButton
	empty.custom_minimum_size.y = 44
	empty.accessibility_name = "Empty destination list"
	empty.clear()
	other.add_child(empty)
	page.note(other, "No destinations available.")
	var disabled := preload("res://rookframe/ui/components/forms/select.tscn").instantiate() as OptionButton
	disabled.custom_minimum_size.y = 44
	disabled.accessibility_name = "Locked destination"
	disabled.add_item("Northern gate", 11)
	disabled.disabled = true
	other.add_child(disabled)

	var menu_example = page.section("Choose a region", "Type while the popup is open to use native incremental search.")
	var choice = Demo.shell_scene(page, "res://rookframe/ui/components/forms/select.tscn", menu_example, {"variant": 1, "accessibility_name": "Campaign region"})
	choice.add_item("Northern frontier", 101)
	choice.add_item("Silver harbour", 205)
	choice.add_item("Closed border — unavailable", 310)
	choice.set_item_disabled(2, true)
	choice.get_popup().allow_search = true
	var menu_status = page.note(menu_example, "Selected ID: 101")
	choice.item_selected.connect(func(index: int): menu_status.text = "Selected ID: %d · %s" % [choice.get_item_id(index), choice.get_item_text(index)])
	var compact := Demo.checkbox(page.flow(menu_example), "Compact density")
	compact.toggled.connect(choice.set_compact)
	var states = page.section("Unavailable and empty", "A disabled choice preserves its selected value. An empty menu has no selected record.")
	var locked = Demo.shell_scene(page, "res://rookframe/ui/components/forms/select.tscn", states, {"variant": 1, "disabled": true, "accessibility_name": "Locked region"})
	locked.add_item("Campaign owner chooses this region", 101)
	var empty_menu = Demo.shell_scene(page, "res://rookframe/ui/components/forms/select.tscn", states, {"variant": 1, "accessibility_name": "Empty region collection"})
	empty_menu.clear()
	page.note(states, "No regions available in the second menu.")
