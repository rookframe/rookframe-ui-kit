extends RefCounted

const Demo = preload("res://examples/components/pages/layout_surfaces/demo.gd")

static func build(page) -> void:
	var first = page.section("Stage and content", "The primary region takes 40% at wide sizes. Both regions stack below the breakpoint.")
	var split = Demo.skin(page, "components/layout/responsive_split.tscn", first)
	Demo.panel(page, split.get_primary_slot(), "Preview", "The observatory at dusk")
	var content = Demo.panel(page, split.get_secondary_slot(), "Scene details", "Edit the title, then resize: the same editor is retained.")
	Demo.editor(content.get_body_slot(), "The observatory", "Scene title")
	var second = page.section("Task and detail · stacked", "A 50/50 recipe with secondary content first in the compact profile.")
	var compact = Demo.skin(page, "components/layout/responsive_split.tscn", second, {"primary_ratio": 0.5, "compact_width": 10000.0, "compact_secondary_first": true})
	Demo.panel(page, compact.get_primary_slot(), "Task", "Inspect the chart and choose a destination.")
	Demo.panel(page, compact.get_secondary_slot(), "Context", "The current route crosses two mountain passes.")
