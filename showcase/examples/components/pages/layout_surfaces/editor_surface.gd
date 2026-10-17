extends RefCounted

const Demo = preload("res://examples/components/pages/layout_surfaces/demo.gd")

static func build(page) -> void:
	for appearance in ["Fantasy", "Cyberpunk"]:
		var body = page.section(appearance + " · auxiliary editor surfaces", "Panel, inset and latest-activity materials express different composition roles.")
		for variation in ["editor_surface_panel", "editor_surface_inset", "editor_surface_log"]:
			var surface = Demo.auxiliary(page, "editor/EditorSurface.tscn", body, appearance, {"theme_type_variation": variation})
			var content := Demo.stack(surface)
			if variation == "editor_surface_log":
				var activity = page.note(content, "Mira moved the observatory marker · just now")
				activity.theme_type_variation = "editor_meta"
			else:
				var title = page.note(content, "Scene properties" if variation == "editor_surface_panel" else "Selection details")
				title.theme_type_variation = "editor_heading"
				var detail = page.note(content, "The observatory · 3 markers")
				detail.theme_type_variation = "editor_body"
