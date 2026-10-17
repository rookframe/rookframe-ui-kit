extends RefCounted

static func build(page) -> void:
	var live = page.section("Filter a collection", "Type a title or clear the query to restore every record.")
	var field = page.scene("res://rookframe/ui/silkbound-ledger/components/forms/search_field.tscn", live, {"label_text": "Find a journal", "placeholder": "Search journals"})
	var result = page.note(live, "Northern roads · Silver harbour · Winter watch")
	field.value_changed.connect(func(query: String):
		var found: PackedStringArray = []
		for title in ["Northern roads", "Silver harbour", "Winter watch"]:
			if query.to_lower() in title.to_lower(): found.append(title)
		result.text = "No matching journals. Clear the search to see all three." if found.is_empty() else " · ".join(found)
	)
	var status = page.note(live, "Search updates as you type.")
	field.value_committed.connect(func(query: String): status.text = "Search submitted: " + query)
	field.cleared.connect(func(): status.text = "Query cleared; focus returned to search.")
	page.button(page.flow(live), "Focus search", field.focus_editor)
	var compact = page.section("Toolbar search", "The label stays available to accessibility tools when visually hidden. The clear action remains visible even when empty.")
	var toolbar = page.scene("res://rookframe/ui/silkbound-ledger/components/forms/search_field.tscn", compact, {"label_text": "Search packages", "show_label": false, "placeholder": "Search packages", "show_clear_when_empty": true})
	var feedback = page.note(compact, "No query.")
	toolbar.value_changed.connect(func(query: String): feedback.text = "Query: " + query if not query.is_empty() else "No query.")
