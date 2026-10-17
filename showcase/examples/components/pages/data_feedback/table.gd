extends RefCounted

const Demo = preload("res://examples/components/pages/data_feedback/demo.gd")

static func build(page) -> void:
	var section = page.section("Read-only records", "The table owns its bounded scrolling. Select a row to read its complete name below.")
	var status = page.note(section, "Select a record.")
	var table := Tree.new()
	table.columns = 3
	table.hide_root = true
	table.column_titles_visible = true
	table.set_column_title(0, "Equipment")
	table.set_column_title(1, "Weight")
	table.set_column_title(2, "Quantity")
	table.set_column_expand(0, true)
	table.set_column_expand(1, false)
	table.set_column_expand(2, false)
	table.set_column_custom_minimum_width(1, 90)
	table.set_column_custom_minimum_width(2, 90)
	table.custom_minimum_size.y = 280
	table.accessibility_name = "Expedition equipment table"
	section.add_child(table)
	var root := table.create_item()
	for record in Demo.records(18):
		var item := table.create_item(root)
		item.set_text(0, record.title)
		item.set_tooltip_text(0, record.title)
		item.set_text(1, record.value)
		item.set_text(2, "2")
		item.set_text_alignment(1, HORIZONTAL_ALIGNMENT_RIGHT)
		item.set_text_alignment(2, HORIZONTAL_ALIGNMENT_RIGHT)
	table.item_selected.connect(func(): status.text = "Selected: " + table.get_selected().get_text(0))
	var empty = page.section("Empty table state")
	page.scene(Demo.path("feedback/task_state"), empty, {"state": 1, "title": "No equipment records", "description": "Add equipment to populate this table."})
