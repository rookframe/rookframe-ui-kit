extends RefCounted

const Demo = preload("res://examples/components/pages/data_feedback/demo.gd")

static func build(page) -> void:
	var basic = page.section("Value and context", "Keep the unit and meaning beside the value.")
	page.scene(Demo.path("data/metric"), basic, {"label_text": "Carrying capacity", "value_text": "24 / 40 kg", "detail_text": "16 kg available"})
	var actionable = page.section("With an action", "Only the action receives keyboard focus.")
	var metric = page.scene(Demo.path("data/metric"), actionable, {"label_text": "Expedition supplies", "value_text": "8 days", "detail_text": "Estimated for four travellers"})
	var status = page.note(actionable, "Supplies are ready.")
	page.button(metric.get_action_slot(), "Review supplies", func(): status.text = "Supply details requested.")
