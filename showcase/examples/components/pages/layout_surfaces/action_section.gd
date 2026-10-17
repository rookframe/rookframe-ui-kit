extends RefCounted

const Demo = preload("res://examples/components/pages/layout_surfaces/demo.gd")

static func build(page) -> void:
	for surface in [0, 1, 2]:
		var body = page.section(["Body surface", "Header surface", "Footer surface"][surface])
		var section = Demo.skin(page, "components/surfaces/action_panel/action_section.tscn", body, {"surface": surface})
		var content := Demo.stack(Demo.inset(section, 12))
		page.note(content, ["Choose the next action for the expedition.", "The northern observatory", "Your progress is retained for this example."][surface])
		if surface == 0:
			var status = page.note(content, "No action selected")
			page.button(content, "Prepare supplies", func(): status.text = "Supplies prepared")
		elif surface == 1:
			page.note(content, "Supporting copy wraps while the leaf grows with its content.")
