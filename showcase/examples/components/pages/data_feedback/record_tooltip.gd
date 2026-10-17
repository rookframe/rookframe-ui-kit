extends RefCounted

const Demo = preload("res://examples/components/pages/data_feedback/demo.gd")

class RecordButton extends Button:
	var record_title := ""
	var summary := ""
	func _make_custom_tooltip(_text: String) -> Object:
		var tooltip = load("res://rookframe/ui/components/feedback/record_tooltip.tscn").instantiate()
		tooltip.get_node("Title").text = record_title
		tooltip.get_node("Summary").text = summary
		return tooltip

static func build(page) -> void:
	for long_copy in [false, true]:
		var section = page.section("Short record summary" if not long_copy else "Long record summary", "Hover for the native tooltip. Activation shows the same essential information below.")
		var button := RecordButton.new()
		button.record_title = "Moonstone compass" if not long_copy else "Lantern of the northern observatory"
		button.summary = "Explorer equipment · 1 kg" if not long_copy else "A lantern carried by the observatory keepers. Its engraved markings record the coastline, mountain passes, and safe camps along the northern route."
		button.text = "Inspect " + button.record_title
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.tooltip_text = button.summary
		button.accessibility_description = button.summary
		button.custom_minimum_size.y = 44
		section.add_child(button)
		var details = page.note(section, "Activate the record to read its details.")
		button.pressed.connect(func(): details.text = button.record_title + " — " + button.summary)
