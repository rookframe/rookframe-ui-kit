extends RefCounted

const Demo = preload("res://examples/components/pages/data_feedback/demo.gd")

static func build(page) -> void:
	var section = page.section("Search and select", "The selected miniature is a draft. Preview art is supplied by this showcase.")
	var status = page.note(section, "Selected: Archivist 1")
	var host = Demo.bounded(section, 430)
	var browser = page.scene(Demo.path("content/miniature_browser"), host, {"paginated": true, "reduced_motion": page.reduced_motion})
	Demo.fill(browser)
	browser.preview_requested.connect(Demo.preview)
	browser.selection_changed.connect(func(entry: Dictionary): status.text = "Selected: " + str(entry.get("title", "None")))
	browser.configure(Demo.miniatures(), "mini-0")
	var states = page.section("Loading, error, and recovery", "These controls update the browser above without replacing the selection.")
	var actions = page.flow(states)
	page.button(actions, "Show loading", func(): browser.set_state("loading", "Loading expedition miniatures…"))
	page.button(actions, "Show error", func(): browser.set_state("error", "Miniatures could not be loaded. Try again."))
	page.button(actions, "Restore records", func(): browser.set_state("ready"))
	browser.retry_requested.connect(func(): browser.set_state("ready"))
	page.button(actions, "Focus selected miniature", func(): browser.focus_entry(str(browser.selection().get("id", "mini-0"))))
