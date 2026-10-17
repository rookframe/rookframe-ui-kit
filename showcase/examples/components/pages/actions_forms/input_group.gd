extends RefCounted

const Demo = preload("res://examples/components/pages/actions_forms/support.gd")

static func build(page) -> void:
	var number = page.section("Number and units", "Units remain outside the editable value.")
	var units = page.scene("res://rookframe/ui/components/forms/input_group.tscn", number)
	var spin := SpinBox.new()
	spin.min_value = 0
	spin.max_value = 100
	spin.value = 12
	spin.accessibility_name = "Travel distance in kilometres"
	spin.custom_minimum_size.y = 44
	units.get_input_slot().add_child(spin)
	var unit = page.note(units.get_trailing_slot(), "km")
	unit.autowrap_mode = TextServer.AUTOWRAP_OFF
	unit.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var distance = page.note(number, "Travel distance: 12 km")
	spin.value_changed.connect(func(value: float): distance.text = "Travel distance: " + str(value) + " km")
	var copy = page.section("Read-only text with Copy", "The input is locked while its Copy action remains available.")
	var group = page.scene("res://rookframe/ui/components/forms/input_group.tscn", copy)
	var identifier := Demo.line(group.get_input_slot(), "Record identifier", "ROOK-0142")
	identifier.editable = false
	var copied = page.note(copy, "Ready to copy.")
	page.button(group.get_trailing_slot(), "Copy", func(): DisplayServer.clipboard_set(identifier.text); copied.text = "Copied record identifier.")
	var search = page.section("Search with Clear", "Clear follows input availability; the complete group shares one focus perimeter.")
	var search_group = page.scene("res://rookframe/ui/components/forms/input_group.tscn", search)
	var query := Demo.line(search_group.get_input_slot(), "Search records", "Winter")
	var clear = page.button(search_group.get_trailing_slot(), "Clear", func(): query.clear(); query.grab_focus())
	var lock := Demo.checkbox(page.flow(search), "Read-only search")
	lock.toggled.connect(func(enabled: bool): query.editable = not enabled; clear.disabled = enabled)
