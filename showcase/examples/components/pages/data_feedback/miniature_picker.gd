extends RefCounted

const Demo = preload("res://examples/components/pages/data_feedback/demo.gd")

static func build(page) -> void:
	var section = page.section("Choose a miniature", "Choosing a card updates the draft. Only Choose confirms it in this example.")
	var status = page.note(section, "No miniature confirmed.")
	var host = Demo.bounded(section, 530)
	var picker = page.scene(Demo.path("content/miniature_picker"), host)
	Demo.fill(picker)
	picker.preview_requested.connect(Demo.preview)
	picker.configure(Demo.miniatures(), "mini-0", {"title": "Choose an expedition miniature", "hint": "Select a card, then confirm with Choose."})
	picker.choose_requested.connect(func(entry: Dictionary): status.text = "Confirmed: " + str(entry.get("title", "")))
	picker.cancel_requested.connect(func(): status.text = "Choice cancelled in this preview.")
	picker.close_requested.connect(func(): status.text = "Close requested in this preview.")
	var recovery = page.section("Unavailable data and retry")
	var actions = page.flow(recovery)
	page.button(actions, "Show loading", func(): picker.set_state("loading", "Preparing previews…"))
	page.button(actions, "Show error", func(): picker.set_state("error", "The miniature package is unavailable."))
	page.button(actions, "Restore picker", func(): picker.set_state("ready"))
	picker.retry_requested.connect(func(): picker.set_state("ready"))
