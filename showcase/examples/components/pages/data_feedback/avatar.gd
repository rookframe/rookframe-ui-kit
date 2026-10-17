extends RefCounted

const Demo = preload("res://examples/components/pages/data_feedback/demo.gd")

static func build(page) -> void:
	var image = page.section("Image and identity", "Avatar art is decorative; the readable identity remains beside it.")
	_avatar(page, image, "Archivist Rowan", "AR", true)
	var fallback = page.section("Missing-image fallbacks", "The host supplies initials. A generic person icon is available when initials are absent.")
	_avatar(page, fallback, "Pathfinder Mira", "PM", false)
	_avatar(page, fallback, "Unknown traveller", "", true)

static func _avatar(page, parent: Node, identity: String, initials: String, use_icon: bool) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 16)
	parent.add_child(row)
	page.scene("res://rookframe/ui/components/data/avatar.tscn", row, {
		"accessibility_name": identity,
		"initials": initials,
		"texture": load("res://rookframe/ui/icons/person.svg") if use_icon else null
	})
	page.note(row, identity)
