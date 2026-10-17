extends RefCounted

const Demo = preload("res://examples/components/pages/layout_surfaces/demo.gd")

static func build(page) -> void:
	for immediate in [false, true]:
		var body = page.section("Reduced motion" if immediate else "Open, close and interrupt", "Toggle again during movement to replace the active transition. The content stays retained.")
		var controls = page.flow(body)
		var bounds := Demo.region(body, 230)
		var leaf = Demo.skin(page, "components/surfaces/hinged_leaf/hinged_leaf.tscn", bounds, {"reduced_motion": immediate or page.reduced_motion})
		leaf.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		leaf.offset_bottom = -32
		var inset := Demo.inset(leaf.get_content(), 24)
		inset.theme = load("res://rookframe/ui/theme/silkbound_theme.tres")
		inset.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		var content := Demo.stack(inset)
		page.note(content, "Expedition notes")
		page.note(content, "A native reading surface that folds without replacing its content.")
		var status = page.note(body, "Open")
		leaf.set_open(true, false)
		leaf.settled.connect(func(open): status.text = "Open" if open else "Closed")
		page.button(controls, "Toggle leaf", func(): leaf.set_open(not leaf.is_open))
		page.button(controls, "Open immediately", func(): leaf.set_open(true, false))
