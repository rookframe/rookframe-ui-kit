extends RefCounted

const Demo = preload("res://examples/components/pages/layout_surfaces/demo.gd")

static func build(page) -> void:
	for compact in [false, true]:
		var body = page.section("Compact · optional regions hidden" if compact else "Complete action panel", "Core sections compose ordinary controls through the public slots.")
		var panel = Demo.component(page, "components/surfaces/action_panel/action_panel.tscn", body, {"compact": compact, "show_emblem": not compact, "show_footer": not compact, "animate_open": false, "reduced_motion": page.reduced_motion})
		page.note(panel.get_header_slot(), "Explore the observatory")
		if not compact:
			var emblem = page.note(panel.get_emblem_slot(), "01")
			emblem.autowrap_mode = TextServer.AUTOWRAP_OFF
		var section = Demo.component(page, "components/surfaces/action_panel/action_section.tscn", panel.get_sections_slot())
		var content := Demo.stack(Demo.inset(section, 12))
		page.note(content, "Search the reading room for notes left by the last astronomer.")
		var status = page.note(content, "Ready")
		page.button(content, "Inspect the desk", func(): status.text = "You discover a handwritten star chart.")
		if not compact:
			page.note(panel.get_footer_slot(), "This example keeps all actions local.")
		var controls = page.flow(body)
		page.button(controls, "Toggle footer", func(): panel.show_footer = not panel.show_footer)
		page.button(controls, "Toggle emblem", func(): panel.show_emblem = not panel.show_emblem)
