extends RefCounted

const Demo = preload("res://examples/components/pages/layout_surfaces/demo.gd")

static func build(page) -> void:
	for rtl in [false, true]:
		var body = page.section("Right to left" if rtl else "Left to right", "The layout changes direction while IDs and paths retain left-to-right text order.")
		var content := Demo.stack(body)
		content.layout_direction = Control.LAYOUT_DIRECTION_RTL if rtl else Control.LAYOUT_DIRECTION_LTR
		page.note(content, "رحلة إلى الشمال" if rtl else "Journey to the north")
		var input := Demo.editor(content, "worlds/north/scene-012", "Scene identifier")
		input.text_direction = Control.TEXT_DIRECTION_LTR
		var row = page.flow(content)
		var status = page.note(content, "Ready")
		page.button(row, "Back", func(): status.text = "Back requested")
		page.button(row, "Continue", func(): status.text = "Continue requested")
