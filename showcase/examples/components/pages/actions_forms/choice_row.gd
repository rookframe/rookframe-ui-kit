extends RefCounted

static func build(page) -> void:
	var main = page.section("Detailed choice", "Choose one travel style. The complete row is one native selection target.")
	var group := ButtonGroup.new()
	var status = page.note(main, "Selected: Explorer")
	for title in ["Explorer", "Storyteller", "Tactician"]:
		var choice = page.scene("res://rookframe/ui/silkbound-ledger/components/forms/choice_row.tscn", main, {"title": title, "description": "Discover places and follow your curiosity." if title == "Explorer" else "A different pace for the same adventure.", "button_group": group, "button_pressed": title == "Explorer"})
		choice.selection_changed.connect(func(selected: bool):
			if selected: status.text = "Selected: " + title
		)
	var variants = page.section("Compact and unavailable", "Independent choices can be toggled without an exclusive group.")
	var compact = page.scene("res://rookframe/ui/silkbound-ledger/components/forms/choice_row.tscn", variants, {"title": "Include travel notes", "description": "Attach the current journal.", "variant": 1})
	var result = page.note(variants, "Travel notes excluded.")
	compact.selection_changed.connect(func(selected: bool): result.text = "Travel notes included." if selected else "Travel notes excluded.")
	page.scene("res://rookframe/ui/silkbound-ledger/components/forms/choice_row.tscn", variants, {"title": "Shared archive", "description": "Requires an available archive.", "variant": 1, "disabled": true, "button_pressed": true})
