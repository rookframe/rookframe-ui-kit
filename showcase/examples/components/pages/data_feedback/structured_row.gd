extends RefCounted

const Demo = preload("res://examples/components/pages/data_feedback/demo.gd")

static func build(page) -> void:
	var variants = ["Data", "Detail", "Compact detail", "Stacked detail", "Summary", "Table", "Header", "Selection banner", "Category", "Catalogue", "Portrait", "Pending"]
	for index in variants.size():
		var section = page.section(variants[index])
		var record = page.scene(Demo.path("data/structured_row"), section, {"variant": index, "title": "Northern observatory", "detail": "An expedition record with supporting context that can wrap on smaller screens.", "value_text": "12 records", "status_text": "Pending review" if index == 11 else "Available"})
		if index in [0, 1, 9]:
			var status = page.note(section, "No action requested.")
			page.button(record.get_action_slot(), "Inspect record", func(): status.text = "Record inspection requested.")
