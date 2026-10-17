extends RefCounted

const Demo = preload("res://examples/components/pages/layout_surfaces/demo.gd")

static func build(page) -> void:
	for compact in [false, true]:
		var body = page.section("Compact toolbar" if compact else "Search and actions", "The same leading and trailing lanes adapt to the measured width.")
		var toolbar = Demo.skin(page, "components/layout/adaptive_toolbar.tscn", body, {"compact_width": 10000.0 if compact else 700.0})
		var search = Demo.editor(toolbar.get_leading_slot(), "", "Filter maps")
		search.placeholder_text = "Filter maps"
		var count = page.note(body, "3 maps available")
		search.text_changed.connect(func(value): count.text = "3 maps available" if value.is_empty() else "Filtering maps by: " + value)
		var filter := OptionButton.new()
		filter.accessibility_name = "Map visibility"
		filter.custom_minimum_size.y = 44
		filter.add_item("All maps")
		filter.add_item("Shared maps")
		toolbar.get_trailing_slot().add_child(filter)
		page.button(toolbar.get_trailing_slot(), "New map", func(): count.text = "New map requested")
