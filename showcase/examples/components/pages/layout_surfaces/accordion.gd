extends RefCounted

const Demo = preload("res://examples/components/pages/layout_surfaces/demo.gd")

static func build(page) -> void:
	for single in [true, false]:
		var body = page.section("Single-open sections" if single else "Multiple-open sections", "All sections may close. Values survive folding and reopening.")
		var group := preload("res://rookframe/ui/components/surfaces/accordion.tres").duplicate() as FoldableGroup if single else null
		for index in 3:
			var fold := preload("res://rookframe/ui/components/surfaces/collapsible.tscn").instantiate() as FoldableContainer
			fold.title = ["Travel preparation", "Supply list", "Field notes"][index]
			fold.foldable_group = group
			fold.folded = index != 0 if single else index == 2
			body.add_child(fold)
			var content := Demo.stack(fold)
			page.note(content, ["Plan the route and choose your next destination.", "Food, shelter and tools for a week away.", "Record discoveries for the next session."][index])
			Demo.editor(content, "Retained notes", fold.title + " notes")
