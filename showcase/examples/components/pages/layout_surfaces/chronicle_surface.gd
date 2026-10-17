extends RefCounted

const Demo = preload("res://examples/components/pages/layout_surfaces/demo.gd")

static func build(page) -> void:
	for appearance in ["Fantasy", "Cyberpunk"]:
		for compact in [false, true]:
			var body = page.section(appearance + (" · compact journal" if compact else " · retained history"), "An auxiliary reading surface for documents and history. Its material does not imply selection or urgency.")
			var suffix := "__compact" if compact else ""
			var surface = Demo.auxiliary(page, "chronicle/ChronicleSurface.tscn", body, appearance, {"theme_type_variation": "chronicle_surface" + suffix})
			var content := Demo.stack(surface)
			var heading = page.note(content, "Beyond the northern road")
			heading.theme_type_variation = "chronicle_heading" + suffix
			var meta = page.note(content, "Session 12 · Mira's journal")
			meta.theme_type_variation = "chronicle_meta" + suffix
			var divider := HSeparator.new()
			divider.theme_type_variation = "chronicle_divider" + suffix
			content.add_child(divider)
			var entry = page.note(content, "We arrived at the observatory at dusk. A lamp still burned in the highest window, though the caretaker had been gone for years. On the desk lay a chart of stars none of us recognized.")
			entry.theme_type_variation = "chronicle_body" + suffix
