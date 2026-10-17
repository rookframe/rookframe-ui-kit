extends RefCounted

const Demo = preload("res://examples/components/pages/actions_forms/support.gd")

static func build(page) -> void:
	var main = page.section("Include resources", "Toggle rows or remove summary items. Clear keeps selected records that are locked.")
	var picker = page.scene("res://rookframe/ui/components/forms/multi_select_picker.tscn", main)
	var records: Array[Dictionary] = [{"id": "rules", "title": "Core rules", "description": "Required by this campaign.", "disabled": true}, {"id": "maps", "title": "Regional maps", "description": "Roads, rivers and settlements."}, {"id": "notes", "title": "Travel notes", "description": "Journals from the last expedition."}]
	picker.set_items(records)
	picker.set_selected_ids(PackedStringArray(["rules", "maps"]))
	var status = page.note(main, "Selected: rules, maps")
	picker.selection_changed.connect(func(ids: PackedStringArray): status.text = "Selected: " + ", ".join(ids))
	var lock := Demo.checkbox(page.flow(main), "Disable picker")
	lock.toggled.connect(func(enabled: bool): picker.disabled = enabled)
	picker.focus_fallback = lock
	var empty = page.section("Empty collection", "No rows means no active Clear action. Load a small collection to try the transition.")
	var other = page.scene("res://rookframe/ui/components/forms/multi_select_picker.tscn", empty)
	var empty_items: Array[Dictionary] = []
	other.set_items(empty_items)
	var state := {"populated": false}
	page.button(page.flow(empty), "Load / empty collection", func():
		state.populated = not state.populated
		var items: Array[Dictionary] = []
		if state.populated: items.append({"id": "archive", "title": "Archive notes"})
		other.set_items(items)
	)
