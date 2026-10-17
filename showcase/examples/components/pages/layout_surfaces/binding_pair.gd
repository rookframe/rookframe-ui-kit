extends RefCounted

const Demo = preload("res://examples/components/pages/layout_surfaces/demo.gd")

static func build(page) -> void:
	for wide in [false, true]:
		var body = page.section("Wide binding" if wide else "Narrow binding", "The core connector has no decoration. Try the action beneath its bounds: input passes through.")
		var bounds := Demo.region(body, 150)
		var action = page.button(bounds, "Connected leaf")
		action.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		var status = page.note(body, "No activation yet")
		action.pressed.connect(func(): status.text = "The native action received the press")
		var binding = Demo.component(page, "components/surfaces/hinged_leaf/binding_pair.tscn", bounds)
		binding.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
		binding.position = Vector2(12, 12)
		binding.size = Vector2(64 if wide else 32, 126)
