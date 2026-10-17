extends RefCounted

const Demo = preload("res://examples/components/pages/layout_surfaces/demo.gd")

static func build(page) -> void:
	var minimal = page.section("Title and supporting copy")
	Demo.skin(page, "components/layout/task_header.tscn", minimal, {"eyebrow": "WORLD", "title": "The northern reaches", "subtitle": "A quiet place to plan the next expedition."})
	var complete = page.section("Actions, progress and tabs", "The task owns values and navigation; the header owns their hierarchy.")
	var header = Demo.skin(page, "components/layout/task_header.tscn", complete, {"eyebrow": "EXPEDITION", "title": "Prepare the next journey", "subtitle": "Long task names and supporting descriptions wrap within the available space.", "use_large_title": true})
	var status = page.note(complete, "Draft saved locally in this example.")
	page.button(header.get_actions_slot(), "Save draft", func(): status.text = "Draft saved.")
	var progress := ProgressBar.new()
	progress.value = 60
	header.get_progress_slot().add_child(progress)
	var tabs := TabBar.new()
	tabs.add_tab("Overview")
	tabs.add_tab("Supplies")
	tabs.add_tab("Route")
	tabs.custom_minimum_size.y = 44
	header.get_tabs_slot().add_child(tabs)
	tabs.tab_changed.connect(func(index): status.text = "Selected: " + tabs.get_tab_title(index))
