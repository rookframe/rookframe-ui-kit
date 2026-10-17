extends RefCounted

static func build(page) -> void:
	var choices = page.section("Choose packages", "Each package is independent. Inclusion is local to this preview.")
	var result = page.note(choices, "Core rules included.")
	for record in [{"title": "Core rules", "detail": "Characters, checks and essential equipment.", "selected": true}, {"title": "Northern frontier", "detail": "Locations and adventures beyond the old road.", "selected": false}]:
		var choice = page.scene("res://rookframe/ui/silkbound-ledger/components/forms/package_choice_card.tscn", choices, {"package_name": record.title, "detail_text": record.detail, "button_pressed": record.selected})
		choice.toggled.connect(func(selected: bool): result.text = record.title + (" included." if selected else " removed."))
	var locked = page.section("Locked inclusion", "Required packages remain selected and visible while unavailable for editing.")
	var choice = page.scene("res://rookframe/ui/silkbound-ledger/components/forms/package_choice_card.tscn", locked, {"package_name": "Campaign foundation", "detail_text": "Required by this campaign; selection is retained while locked.", "button_pressed": true, "disabled": true})
	var unlock = page.button(page.flow(locked), "Unlock package")
	unlock.pressed.connect(func(): choice.disabled = not choice.disabled; unlock.text = "Unlock package" if choice.disabled else "Lock package")
