extends RefCounted

const Demo = preload("res://examples/components/pages/data_feedback/demo.gd")

static func build(page) -> void:
	var section = page.section("Action menu", "Menu activation requests an action; it does not change a field value.")
	var status = page.note(section, "No action requested.")
	var menu := preload("res://rookframe/ui/components/overlays/dropdown_menu.tscn").instantiate() as MenuButton
	menu.text = "Expedition actions"
	menu.custom_minimum_size.y = 44
	menu.get_popup().add_item("Inspect", 10)
	menu.get_popup().add_item("Duplicate", 20)
	menu.get_popup().add_separator()
	menu.get_popup().add_item("Delete unavailable expedition", 30)
	menu.get_popup().set_item_disabled(3, true)
	menu.get_popup().allow_search = true
	menu.get_popup().id_pressed.connect(func(id: int): status.text = "Requested: " + {10: "Inspect", 20: "Duplicate"}[id])
	section.add_child(menu)
	var unavailable = page.section("Unavailable trigger")
	var disabled_menu := preload("res://rookframe/ui/components/overlays/dropdown_menu.tscn").instantiate() as MenuButton
	disabled_menu.text = "Actions unavailable"
	disabled_menu.disabled = true
	disabled_menu.custom_minimum_size.y = 44
	unavailable.add_child(disabled_menu)
	page.note(unavailable, "Connect to a world to make its actions available.")
