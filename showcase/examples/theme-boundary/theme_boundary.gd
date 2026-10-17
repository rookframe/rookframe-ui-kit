extends Control
## Identical public component scenes with native defaults or a selected Theme.
func _ready() -> void:
	var scroll := ScrollContainer.new()
	add_child(scroll)
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var columns := HBoxContainer.new()
	columns.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(columns)
	for themed in [false, true]:
		var column := VBoxContainer.new()
		column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		if themed:
			column.theme = preload("res://rookframe/ui/themes/silkbound-ledger/theme.tres")
		columns.add_child(column)
		var heading := Label.new()
		heading.text = "Silkbound Ledger" if themed else "Native defaults"
		column.add_child(heading)
		var prefix := "res://rookframe/ui/"
		var field = load(prefix + "components/forms/text_field.tscn").instantiate()
		field.label_text = "Character name"
		field.value = "The archivist"
		column.add_child(field)
		var search = load(prefix + "components/forms/search_field.tscn").instantiate()
		search.value = "Retained query"
		column.add_child(search)
		var notice = load(prefix + "components/feedback/notice.tscn").instantiate()
		notice.title = "Connection unavailable"
		notice.description = "Your draft remains available. Try again when ready."
		notice.tone = 3
		column.add_child(notice)
		var choices = load(prefix + "components/data/paginated_choices.tscn").instantiate()
		choices.custom_minimum_size.y = 240
		choices.reduced_motion = true
		column.add_child(choices)
		var entries: Array[Dictionary] = []
		for i in 8:
			entries.append({"id": str(i), "title": "Record %d" % (i + 1), "subtitle": "A retained record", "value": str(i + 12)})
		choices.configure(entries, "1", "Records", "8")
		var action = load(prefix + "menu/MenuButtonStandard.tscn").instantiate()
		action.text = "Continue"
		action.disabled = true
		column.add_child(action)
