extends RefCounted

const Demo = preload("res://examples/components/pages/data_feedback/demo.gd")

static func build(page) -> void:
	var section = page.section("Task completion")
	var status = page.note(section, "Preparing assets: 4 / 10")
	var bar := ProgressBar.new()
	bar.max_value = 10
	bar.value = 4
	bar.custom_minimum_size.y = 28
	bar.accessibility_name = status.text
	section.add_child(bar)
	var actions = page.flow(section)
	page.button(actions, "Complete next asset", func():
		bar.value = minf(bar.value + 1, bar.max_value)
		status.text = "Preparing assets: %d / 10" % bar.value
		bar.accessibility_name = status.text)
	page.button(actions, "Restart progress", func():
		bar.value = 0
		status.text = "Preparing assets: 0 / 10"
		bar.accessibility_name = status.text)
	var resources = page.section("Character resources", "A label states the resource and its finite maximum.")
	for data in [["Health", 75, 100], ["Mana", 20, 50], ["Stamina", 0, 60]]:
		var copy := "%s: %d / %d" % data
		page.note(resources, copy)
		var meter := ProgressBar.new()
		meter.max_value = data[2]
		meter.value = data[1]
		meter.custom_minimum_size.y = 28
		meter.accessibility_name = copy
		resources.add_child(meter)
