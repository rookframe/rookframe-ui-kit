@tool
extends VBoxContainer
const Appearance = preload("res://rookframe/ui/_internal/presentation/appearance.gd")
## Content-sized linked leaves. Game rules and all interactive children belong to the caller.
## Add ordinary Controls to the four slots, in the editor or through the getters.
@export var animate_open := true
@export var reduced_motion := false

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

func linked_leaves() -> Array[Control]:
	var leaves: Array[Control] = [get_node("Header/Leaf")]
	for section in get_sections_slot().get_children():
		if section is Control and section.is_visible_in_tree(): leaves.append(section)
	if show_footer: leaves.append(get_node("Footer/Leaf"))
	return leaves

func _ready() -> void:
	resized.connect(_refresh_decoration)
	for path in ["Header", "Header/Leaf", "Sections", "Footer", "Footer/Leaf"]:
		get_node(path).item_rect_changed.connect(_refresh_decoration)
	get_sections_slot().child_order_changed.connect(_sections_changed)
	_refresh_layout()
	_sections_changed()

func _sections_changed() -> void:
	if not is_inside_tree() or not has_node("Sections/SectionsSlot"):
		return
	for child in get_sections_slot().get_children():
		if child is Control:
			if not child.item_rect_changed.is_connected(_refresh_decoration):
				child.item_rect_changed.connect(_refresh_decoration)
			if not child.visibility_changed.is_connected(_refresh_decoration):
				child.visibility_changed.connect(_refresh_decoration)
	_refresh_decoration()

func _refresh_layout() -> void:
	if not is_node_ready():
		return
	var header: MarginContainer = get_node("Header")
	header.custom_minimum_size.y = (44 if compact else 56) if show_emblem else 0
	_style_layout(header)
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

func _style_layout(header: MarginContainer) -> void:
	if Appearance.has_hook(self, &"_style_layout"):
		Appearance.invoke(self, &"_style_layout", [header])
		return
	pass


func _enter_tree() -> void:
	preload("res://rookframe/ui/_internal/presentation/binding.gd").attach(self)

func _presentation_will_change() -> void:
	get_node("DropMotion").finish()

func _presentation_changed() -> void:
	_refresh_layout()
