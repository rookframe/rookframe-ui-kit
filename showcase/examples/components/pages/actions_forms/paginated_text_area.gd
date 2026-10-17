extends RefCounted

const Demo = preload("res://examples/components/pages/actions_forms/support.gd")

static func build(page) -> void:
	var main = page.section("Long journal", "Page controls sit in the owning footer. Edit any page; the complete draft remains intact.")
	var value := "The company reached the northern gate before dusk. We recorded the weather, supplies and names of travellers.\n\n".repeat(18)
	var editor = page.scene("res://rookframe/ui/components/forms/paginated_text_area.tscn", main, {"value": value, "reduced_motion": page.reduced_motion})
	editor.custom_minimum_size.y = 220
	main.add_child(editor.get_pager())
	var status = page.note(main, "%d characters in the complete draft." % value.length())
	editor.value_changed.connect(func(next: String): status.text = "%d characters in the complete draft." % next.length())
	var compact := Demo.checkbox(page.flow(main), "Compact typography")
	compact.toggled.connect(func(enabled: bool): editor.compact = enabled)
	var short = page.section("Single page", "Short content has no pager. Adding enough text reveals it automatically.")
	var note = page.scene("res://rookframe/ui/components/forms/paginated_text_area.tscn", short, {"value": "Remember to visit the archivist.", "reduced_motion": page.reduced_motion})
	note.custom_minimum_size.y = 180
	short.add_child(note.get_pager())
	page.button(page.flow(short), "Add a paragraph", func(): note.value += "\nThe archivist keeps a record of every ship that entered the harbour this season.")
