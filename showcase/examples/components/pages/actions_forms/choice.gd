extends RefCounted

static func build(page) -> void:
	var main = page.section("Independent choice", "The complete target toggles once. Labels and selection rules belong to the host.")
	var choice = page.scene("res://rookframe/ui/components/forms/choice.tscn", main, {"title": "Include travel notes", "description": "Attach the current journal."})
	var status = page.note(main, "Travel notes excluded.")
	choice.toggled.connect(func(selected: bool): status.text = "Travel notes included." if selected else "Travel notes excluded.")
	var options = page.section("Exclusive rows", "A native ButtonGroup keeps one option selected.")
	var group := ButtonGroup.new()
	for title in ["Explorer", "Storyteller", "Tactician"]:
		page.scene("res://rookframe/ui/components/forms/choice.tscn", options, {"title": title, "description": "A different pace for the same adventure.", "button_group": group, "button_pressed": title == "Explorer"})
	var variants = page.section("Presentation variants", "Card, marked row, marked card and list share the same selection behavior.")
	for variant in [1, 2, 3, 4]:
		page.scene("res://rookframe/ui/components/forms/choice.tscn", variants, {"variant": variant, "title": "Campaign foundation", "description": "Characters, checks and essential equipment.", "action_label": "Include", "selected_label": "Included", "marker_text": "P", "value_text": "v2" if variant == 4 else ""})
	var states = page.section("Compact and unavailable", "Density and description visibility are independent. Disabled choices retain their state.")
	page.scene("res://rookframe/ui/components/forms/choice.tscn", states, {"title": "Compact row", "description": "This description is hidden.", "compact": true, "show_description": false})
	for selected in [false, true]:
		page.scene("res://rookframe/ui/components/forms/choice.tscn", states, {"variant": 1, "title": "Shared campaign archive", "description": "A longer translated description stays readable when the available width becomes small.", "compact": true, "disabled": true, "button_pressed": selected})
