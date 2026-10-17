extends RefCounted

const Demo = preload("res://examples/components/pages/layout_surfaces/demo.gd")

static func build(page) -> void:
	var horizontal = page.section("Horizontal separation")
	page.note(horizontal, "Session notes")
	horizontal.add_child(preload("res://rookframe/ui/components/layout/separator.tscn").instantiate() as HSeparator)
	page.note(horizontal, "A new entry begins below the rule.")
	var vertical = page.section("Vertical separation", "Only the actions receive keyboard focus.")
	var row := HBoxContainer.new()
	vertical.add_child(row)
	var status = page.note(vertical, "Choose an action")
	page.button(row, "Copy", func(): status.text = "Copy requested")
	row.add_child(preload("res://rookframe/ui/components/layout/vertical_separator.tscn").instantiate() as VSeparator)
	page.button(row, "Share", func(): status.text = "Share requested")
