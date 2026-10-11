@tool
extends VBoxContainer
## Content-sized linked leaves. Game rules and all interactive children belong to the caller.
## Add ordinary Controls to the four slots, in the editor or through the getters.

@export var compact := false:
	set(value):
		compact = value
		_refresh_layout()
@export var show_footer := true:
	set(value):
		show_footer = value
		_refresh_layout()
@export var show_emblem := true:
	set(value):
		show_emblem = value
		_refresh_layout()

func get_header_slot() -> VBoxContainer:
	return get_node("Header/Leaf/HeaderSlot")
func get_emblem_slot() -> CenterContainer:
	return get_node("Header/Emblem/Leaf/EmblemSlot")
func get_sections_slot() -> VBoxContainer:
	return get_node("Sections/SectionsSlot")
func get_footer_slot() -> VBoxContainer:
	return get_node("Footer/Leaf/FooterSlot")

func _ready() -> void:
	resized.connect(_refresh_decoration)
	get_node("Header").resized.connect(_refresh_decoration)
	get_node("Sections").resized.connect(_refresh_decoration)
	get_node("Footer").resized.connect(_refresh_decoration)
	get_sections_slot().child_order_changed.connect(_sections_changed)
	_refresh_layout()
	_sections_changed()

func _sections_changed() -> void:
	if not is_inside_tree() or not has_node("Sections/SectionsSlot"):
		return
	for child in get_sections_slot().get_children():
		if child is Control:
			if not child.resized.is_connected(_refresh_decoration):
				child.resized.connect(_refresh_decoration)
			if not child.visibility_changed.is_connected(_refresh_decoration):
				child.visibility_changed.connect(_refresh_decoration)
	_refresh_decoration()

func _refresh_layout() -> void:
	if not is_node_ready():
		return
	var header: MarginContainer = get_node("Header")
	header.custom_minimum_size.y = (44 if compact else 56) if show_emblem else 0
	header.add_theme_constant_override("margin_left", (48 if compact else 76) if show_emblem else 18)
	header.add_theme_constant_override("margin_right", 20 if compact else 62)
	get_node("Sections").add_theme_constant_override("margin_left", 8 if compact else 18)
	get_node("Footer").add_theme_constant_override("margin_left", 28 if compact else 78)
	get_node("Footer").add_theme_constant_override("margin_right", 8 if compact else 26)
	get_node("Footer").add_theme_constant_override("margin_top", 4 if compact else 5)
	get_node("Footer").visible = show_footer
	get_node("Header/Emblem").visible = show_emblem
	_refresh_decoration()

func _refresh_decoration() -> void:
	if not is_node_ready():
		return
	var emblem: PanelContainer = get_node("Header/Emblem/Leaf")
	emblem.size = Vector2(52, 44) if compact else Vector2(82, 56)
	emblem.position = Vector2(0, maxf(0, (get_node("Header").size.y - emblem.size.y) * .5))
	get_node("Connectors").queue_redraw()
