extends RefCounted

const Demo = preload("res://examples/components/pages/layout_surfaces/demo.gd")

static func build(page) -> void:
	for compact in [false, true]:
		var body = page.section("Stacked actions" if compact else "Leading and trailing actions", "Each action remains independent. Resize to exercise the adaptive profile.")
		var bar = Demo.skin(page, "components/layout/action_bar.tscn", body, {"compact_width": 10000.0 if compact else 560.0})
		var status = page.note(body, "Ready to continue")
		page.button(bar.get_leading_slot(), "Back", func(): status.text = "Back requested")
		page.button(bar.get_trailing_slot(), "Cancel", func(): status.text = "Cancel requested")
		page.button(bar.get_trailing_slot(), "Continue", func(): status.text = "Continue requested")
