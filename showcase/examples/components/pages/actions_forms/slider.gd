extends RefCounted

const Demo = preload("res://examples/components/pages/actions_forms/support.gd")

static func build(page) -> void:
	var main = page.section("Volume", "Adjust with pointer, keyboard arrows or controller. Values range from 0 to 100 percent.")
	var slider := preload("res://rookframe/ui/components/forms/slider.tscn").instantiate() as HSlider
	slider.min_value = 0
	slider.max_value = 100
	slider.step = 1
	slider.value = 65
	slider.custom_minimum_size.y = 44
	slider.accessibility_name = "Volume, zero to one hundred percent"
	main.add_child(slider)
	var status = page.note(main, "Volume: 65%")
	slider.value_changed.connect(func(value: float): status.text = "Volume: %d%%" % value)
	var disable := Demo.checkbox(page.flow(main), "Lock volume")
	disable.toggled.connect(func(enabled: bool): slider.editable = not enabled)
	var stepped = page.section("Stepped distance", "A five-kilometre step makes the allowed increments visible.")
	var distance := preload("res://rookframe/ui/components/forms/slider.tscn").instantiate() as HSlider
	distance.min_value = 5
	distance.max_value = 50
	distance.step = 5
	distance.value = 20
	distance.tick_count = 10
	distance.ticks_on_borders = true
	distance.custom_minimum_size.y = 44
	distance.accessibility_name = "Travel distance, five to fifty kilometres in steps of five"
	stepped.add_child(distance)
	var result = page.note(stepped, "Distance: 20 km")
	distance.value_changed.connect(func(value: float): result.text = "Distance: %d km" % value)
