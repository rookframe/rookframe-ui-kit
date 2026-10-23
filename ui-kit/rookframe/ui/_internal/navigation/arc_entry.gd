@tool
extends Button
## One ArcPicker toggle: an icon category or a previewed item. The Well's
## stylebox is the preview's clip mask, so the Theme decides its shape.

enum Kind { CATEGORY, ITEM }

const THEME_TYPES: Array[StringName] = [&"RookframeArcCategory", &"RookframeArcItem"]
const DIAMETERS: Array[int] = [52, 76]

var kind := Kind.ITEM:
	set(value):
		kind = value
		_refresh()

var entry_id := ""

var title := "":
	set(value):
		title = value
		_refresh()

var preview: Texture2D:
	set(value):
		preview = value
		_refresh()


func _ready() -> void:
	toggled.connect(func(_on: bool): _refresh_marker())
	_refresh()


func _notification(what: int) -> void:
	if what == NOTIFICATION_THEME_CHANGED and is_node_ready():
		_refresh()


func _refresh() -> void:
	if not is_node_ready():
		return
	theme_type_variation = THEME_TYPES[kind]
	# Category art of any import size scales into the ring; native icon_max_width still caps it.
	expand_icon = kind == Kind.CATEGORY
	var diameter := maxi(44, get_theme_constant(&"diameter") if has_theme_constant(&"diameter") else DIAMETERS[kind])
	custom_minimum_size = Vector2(diameter, diameter)
	accessibility_name = title
	tooltip_text = title
	var inset := float(get_theme_constant(&"well_inset") if has_theme_constant(&"well_inset") else 4)
	$Well.visible = kind == Kind.ITEM
	$Well.set_anchors_and_offsets_preset(PRESET_FULL_RECT, PRESET_MODE_MINSIZE, int(inset))
	$Well/Preview.texture = preview
	_refresh_marker()


func _refresh_marker() -> void:
	# Selection is never colour alone: a mark accompanies the pressed ring.
	var mark := get_theme_icon(&"selection_mark") if has_theme_icon(&"selection_mark") else get_theme_icon(&"checked", &"CheckBox")
	$Marker.texture = mark
	$Marker.visible = button_pressed and kind == Kind.ITEM
	var mark_size := mark.get_size() if mark != null else Vector2.ZERO
	$Marker.offset_left = -mark_size.x
	$Marker.offset_top = -mark_size.y
