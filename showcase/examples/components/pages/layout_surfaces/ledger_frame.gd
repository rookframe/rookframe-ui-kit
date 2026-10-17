extends RefCounted

const Demo = preload("res://examples/components/pages/layout_surfaces/demo.gd")

static func build(page) -> void:
	for footer in [true, false]:
		var body = page.section("Header, body and footer" if footer else "Header and body", "Core frames have no decoration or reveal shader. Content remains visible and reveal settles immediately.")
		var bounds := Demo.region(body, 320 if footer else 250)
		var frame = Demo.component(page, "components/surfaces/ledger_frame.tscn", bounds, {"reduced_motion": page.reduced_motion})
		frame.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		var content := Control.new()
		bounds.add_child(content)
		content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		var header = page.label("SESSION CHRONICLE\nThe road into the mountains")
		content.add_child(header)
		var narrative = page.label("At dusk, the expedition reached the old observatory and discovered that its doors were already open. A lamp burned in the highest window.")
		content.add_child(narrative)
		var credit = page.label("Recorded by Mira · Session 12")
		content.add_child(credit)
		credit.visible = footer
		var arrange = func():
			var width = maxf(1.0, bounds.size.x - 12.0)
			frame.set_sections(Rect2(6, 4, width, 82), Rect2(6, 98, width, 142), Rect2(6, 252, width, 58) if footer else Rect2())
			header.position = Vector2(24, 19)
			header.size = Vector2(width - 36, 52)
			narrative.position = Vector2(24, 115)
			narrative.size = Vector2(width - 36, 108)
			credit.position = Vector2(24, 266)
			credit.size = Vector2(width - 36, 30)
		bounds.resized.connect(arrange)
		arrange.call_deferred()
		page.button(body, "Reveal content", func(): frame.reveal(content))
