extends RefCounted

static func build(page) -> void:
	var main = page.section("Quick actions", "Resize the view to see the grid move between one and two columns.")
	var grid = page.scene("res://rookframe/ui/silkbound-ledger/components/data/icon_action_grid.tscn", main)
	var status = page.note(main, "Choose an action.")
	for item in [{"title": "New journal", "icon": "edit"}, {"title": "Browse maps", "icon": "folder"}, {"title": "Roll dice", "icon": "dice"}, {"title": "Party details", "icon": "person"}]:
		var action = page.button(grid, item.title, func(): status.text = "Requested: " + item.title)
		action.icon = load("res://rookframe/ui/icons/" + item.icon + ".svg")
		action.expand_icon = true
		action.add_theme_constant_override("icon_max_width", 24)
	var layout = page.note(main, "Columns follow the available width.")
	grid.column_count_changed.connect(func(count: int): layout.text = "%d columns" % count)
	var limited = page.section("Single column and disabled action", "A one-column grid keeps the same action order and target size.")
	var single = page.scene("res://rookframe/ui/silkbound-ledger/components/data/icon_action_grid.tscn", limited, {"maximum_columns": 1})
	var feedback = page.note(limited, "Archive is locked.")
	page.button(single, "Open local journal", func(): feedback.text = "Local journal requested.")
	var unavailable = page.button(single, "Open shared archive")
	unavailable.disabled = true
