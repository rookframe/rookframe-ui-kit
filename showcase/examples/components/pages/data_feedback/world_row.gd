extends RefCounted

const Demo = preload("res://examples/components/pages/data_feedback/demo.gd")

static func build(page) -> void:
	var section = page.section("Select a world", "Selection belongs to the containing screen.")
	var status = page.note(section, "Selected: The northern reach")
	var rows: Array[Button] = []
	for index in 3:
		var row = page.scene(Demo.path("data/world_row"), section, {"title": ["The northern reach", "Across the glass desert", "The sealed archive"][index], "detail_text": ["4 players · Last visited today", "2 players · Private world", "Unavailable while its package is missing"][index], "selected": index == 0, "disabled": index == 2})
		rows.append(row)
		row.pressed.connect(func():
			for candidate in rows: candidate.selected = candidate == row
			status.text = "Selected: " + row.title)
	var disabled_state = page.section("Selected and unavailable")
	page.scene(Demo.path("data/world_row"), disabled_state, {"title": "The distant coast", "detail_text": "This world remains selected while disconnected.", "selected": true, "disabled": true})
