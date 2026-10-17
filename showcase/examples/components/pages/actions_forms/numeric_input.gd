extends RefCounted

const Demo = preload("res://examples/components/pages/actions_forms/support.gd")

static func build(page) -> void:
	var main = page.section("Bounded quantity", "Arrows update immediately. Typed values commit on Enter or focus exit.")
	var field = page.scene("res://rookframe/ui/components/forms/field.tscn", main, {"label_text": "Party size", "help_text": "Choose between one and eight travellers."})
	var spin := SpinBox.new()
	spin.min_value = 1
	spin.max_value = 8
	spin.step = 1
	spin.value = 4
	spin.custom_minimum_size.y = 44
	field.get_input_slot().add_child(spin)
	field.set_target(spin)
	var status = page.note(main, "Travellers: 4")
	spin.value_changed.connect(func(value: float): status.text = "Travellers: %d" % value)
	var other = page.section("Decimal units and read-only", "The native bounds and quarter-unit step apply to typed and arrow input.")
	var units = page.scene("res://rookframe/ui/components/forms/input_group.tscn", other)
	var distance := SpinBox.new()
	distance.min_value = 0
	distance.max_value = 10
	distance.step = 0.25
	distance.value = 2.5
	distance.custom_minimum_size.y = 44
	distance.accessibility_name = "Travel distance in kilometres, zero to ten"
	units.get_input_slot().add_child(distance)
	var unit = page.note(units.get_trailing_slot(), "km")
	unit.autowrap_mode = TextServer.AUTOWRAP_OFF
	unit.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var result = page.note(other, "Travel distance: 2.5 km")
	distance.value_changed.connect(func(value: float): result.text = "Travel distance: " + str(value) + " km")
	var lock := Demo.checkbox(page.flow(other), "Read-only value")
	lock.toggled.connect(func(enabled: bool): distance.editable = not enabled)
