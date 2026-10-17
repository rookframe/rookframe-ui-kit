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
	var frame := PanelContainer.new()
	frame.custom_minimum_size = Vector2(64, 64)
	frame.accessibility_name = identity
	row.add_child(frame)
	if use_icon:
		var art := TextureRect.new()
		art.texture = load("res://rookframe/ui/icons/person.svg")
		art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		art.mouse_filter = Control.MOUSE_FILTER_IGNORE
		frame.add_child(art)
	else:
		var copy = page.label(initials)
		copy.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		copy.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		frame.add_child(copy)
	page.note(row, identity)
