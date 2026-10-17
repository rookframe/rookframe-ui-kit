extends RefCounted

const Demo = preload("res://examples/components/pages/layout_surfaces/demo.gd")

static func build(page) -> void:
	for appearance in ["Fantasy", "Cyberpunk"]:
		var body = page.section(appearance + " · auxiliary menu surfaces", "Compare a grouped menu backdrop with the distinct material for one World summary.")
		for record in [false, true]:
			var bounds := Demo.region(body, 190)
			var surface = Demo.auxiliary(page, "menu/MenuSurface.tscn", bounds, appearance, {"theme_type_variation": "menu_world_record" if record else "menu_group"})
			surface.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			var inset := Demo.inset(surface, 20)
			inset.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			var content := Demo.stack(inset)
			var title = page.note(content, "The northern reaches" if record else "Choose your next adventure")
			title.theme_type_variation = "menu_world_title" if record else "menu_identity_label"
			var copy = page.note(content, "A shared world for your next expedition." if record else "A backdrop for related menu actions.")
			copy.theme_type_variation = "menu_world_description" if record else "menu_description"
			if record:
				var metadata = page.note(content, "3 players · Last opened today")
				metadata.theme_type_variation = "menu_world_metadata"
