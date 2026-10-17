extends RefCounted

const Demo = preload("res://examples/components/pages/layout_surfaces/demo.gd")

static func build(page) -> void:
	for compact in [false, true]:
		var body = page.section("Compact journal" if compact else "Retained history", "A native reading surface for documents and history. Semantic roles inherit the default styling.")
		var suffix := "__compact" if compact else ""
		var surface = Demo.component(page, "chronicle/ChronicleSurface.tscn", body, {"theme_type_variation": "chronicle_surface" + suffix})
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
