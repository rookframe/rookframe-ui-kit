extends RefCounted

const Demo = preload("res://examples/components/pages/layout_surfaces/demo.gd")

static func build(page) -> void:
	for open in [true, false]:
		var body = page.section("Initially open" if open else "Initially closed", "Open, edit and close the section. Its editor keeps the same value.")
		var fold := preload("res://rookframe/ui/components/surfaces/collapsible.tscn").instantiate() as FoldableContainer
		fold.title = "Additional notes"
		fold.folded = not open
		body.add_child(fold)
		var content := Demo.stack(fold)
		page.note(content, "Optional details that can stay out of the main reading flow.")
		Demo.editor(content, "Meet at the west gate", "Additional notes")
