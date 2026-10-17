extends RefCounted

const Demo = preload("res://examples/components/pages/data_feedback/demo.gd")

static func build(page) -> void:
	var section = page.section("Paged selection", "Previous and Next change the visible page; choosing a row changes selection.")
	var status = page.note(section, "Selected: item-0")
	var host = Demo.bounded(section, 350)
	var choices = page.scene(Demo.path("data/paginated_choices"), host, {"framed_collection": true, "reduced_motion": page.reduced_motion})
	Demo.fill(choices)
	var records: Array[Dictionary] = Demo.records(16)
	choices.configure(records, "item-0", "Choose equipment", "16 entries")
	choices.selected.connect(func(id: String):
		choices.configure(records, id, "Choose equipment", "16 entries")
		status.text = "Selected: " + id)
	var actions = page.flow(section)
	page.button(actions, "Focus final entry", func(): choices.focus_entry("item-15"))
	var snapshot := [{}]
	page.button(actions, "Remember page", func():
		snapshot[0] = choices.capture_state()
		status.text = "Visible page remembered.")
	page.button(actions, "Restore page", func(): choices.restore_state(snapshot[0]))
	var empty = page.section("Framed empty collection", "The framed presentation retains its footer even when there are no entries.")
	var empty_host = Demo.bounded(empty, 180)
	var empty_choices = page.scene(Demo.path("data/paginated_choices"), empty_host, {"framed_collection": true, "empty_text": "No equipment has been added."})
	Demo.fill(empty_choices)
	var no_entries: Array[Dictionary] = []
	empty_choices.configure(no_entries, "", "Equipment", "0 entries")
