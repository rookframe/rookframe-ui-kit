extends RefCounted

const Demo = preload("res://examples/components/pages/layout_surfaces/demo.gd")

static func build(page) -> void:
	var responsive = page.section("Responsive columns", "Resize the gallery: four equal cells fall back to fewer columns without losing their values.")
	var grid = Demo.component(page, "components/layout/adaptive_grid.tscn", responsive, {"maximum_columns": 4, "minimum_column_width": 180.0})
	for item in ["North", "East", "South", "West"]:
		var card = Demo.panel(page, grid, item, "Expedition supplies")
		Demo.editor(card.get_body_slot(), "12", item + " supplies")
	var count = page.note(responsive, "Columns adapt to available width.")
	grid.column_count_changed.connect(func(columns): count.text = "%d columns · same four controls" % columns)
	var stacked = page.section("Single column", "Use an explicit one-column limit for a reading sequence.")
	var list = Demo.component(page, "components/layout/adaptive_grid.tscn", stacked, {"maximum_columns": 1})
	for item in ["Prepare", "Travel", "Rest"]:
		Demo.panel(page, list, item, "Each stage remains in source order.")
