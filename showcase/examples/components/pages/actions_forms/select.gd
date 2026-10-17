extends RefCounted

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
