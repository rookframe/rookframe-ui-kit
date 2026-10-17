extends RefCounted

const Demo = preload("res://examples/components/pages/data_feedback/demo.gd")

static func build(page) -> void:
	for long_content in [true, false]:
		var section = page.section("Multiple reading pages" if long_content else "Single page with persistent pager", "Page boundaries use native text measurements. Keyboard focus reveals the page containing an action.")
		var host = Demo.bounded(section, 280 if long_content else 180)
		var content = load(Demo.path("data/paginated_content")).instantiate()
		content.always_show_pager = true
		content.reduced_motion = page.reduced_motion
		var column := VBoxContainer.new()
		content.get_node("Area").add_child(column)
		for index in (8 if long_content else 1):
			page.note(column, "Entry %d — The expedition follows the coast toward the northern observatory. Record the safe camps and mountain passes before departing." % (index + 1))
		var status = page.note(section, "No bookmark set.")
		page.button(column, "Bookmark this entry", func(): status.text = "Entry bookmarked in this preview.")
		# PaginatedContent discovers the authored Area child at tree entry.
		host.add_child(content)
		Demo.fill(content)
