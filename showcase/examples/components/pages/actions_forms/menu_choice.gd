extends RefCounted

const Demo = preload("res://examples/components/pages/actions_forms/support.gd")

static func build(page) -> void:
	var main = page.section("Choose a region", "Type while the popup is open to use native incremental search.")
	Demo.shell_materials(page, main)
	var choice = Demo.shell_scene(page, "res://rookframe/ui/menu/MenuChoice.tscn", main, {"accessibility_name": "Campaign region"})
	choice.add_item("Northern frontier", 101)
	choice.add_item("Silver harbour", 205)
	choice.add_item("Closed border — unavailable", 310)
	choice.set_item_disabled(2, true)
	choice.get_popup().allow_search = true
	var status = page.note(main, "Selected ID: 101")
	choice.item_selected.connect(func(index: int): status.text = "Selected ID: %d · %s" % [choice.get_item_id(index), choice.get_item_text(index)])
	var compact := Demo.checkbox(page.flow(main), "Compact density")
	compact.toggled.connect(choice.set_compact)
	var states = page.section("Unavailable and empty", "A disabled choice preserves its selected value. An empty menu has no selected record.")
	var locked = Demo.shell_scene(page, "res://rookframe/ui/menu/MenuChoice.tscn", states, {"disabled": true, "accessibility_name": "Locked region"})
	locked.add_item("Campaign owner chooses this region", 101)
	var empty = Demo.shell_scene(page, "res://rookframe/ui/menu/MenuChoice.tscn", states, {"accessibility_name": "Empty region collection"})
	empty.clear()
	page.note(states, "No regions available in the second menu.")
