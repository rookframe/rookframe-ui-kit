@tool
extends "res://rookframe/ui/components/data/collection.gd"

func _draw() -> void:
	if not is_node_ready():
		return
	if divider_top and get_node(^"Content/Caption").visible:
		draw_line(Vector2.ZERO, Vector2(size.x, 0), Color("3e4346"))
	if get_node(^"Content/Caption").visible:
		draw_line(Vector2(0, get_node(^"Content/Caption").size.y + get_theme_constant("margin_top")), Vector2(size.x, get_node(^"Content/Caption").size.y + get_theme_constant("margin_top")), Color("5b6265"))
	var pager := get_node(^"Content/Pager") as Control
	if not pager.visible:
		return
	draw_line(Vector2(get_theme_constant("margin_left"), pager.position.y + get_theme_constant("margin_top")), Vector2(size.x - get_theme_constant("margin_right"), pager.position.y + get_theme_constant("margin_top")), Color("3e4346"))

const MEDIUM = preload("res://rookframe/ui/theme/silkbound_medium.tres")
const REGULAR = preload("res://rookframe/ui/theme/silkbound_regular.tres")
var _title_font: FontVariation
var _subtitle_font: FontVariation


func _ready() -> void:
	_title_font = MEDIUM.duplicate()
	_subtitle_font = REGULAR.duplicate()
	super._ready()

func _style_action(action: Button) -> void:
	for state in ["normal", "hover", "pressed", "hover_pressed", "disabled"]:
		var frame := action.get_theme_stylebox(state).duplicate() as StyleBoxFlat
		frame.content_margin_left = 8 if action.icon != null else 10
		frame.content_margin_right = frame.content_margin_left
		frame.content_margin_top = 8 if action.icon != null else 6
		frame.content_margin_bottom = frame.content_margin_top
		frame.bg_color = Color("ceccb3") if action.button_pressed else Color("343d41") if state in ["hover", "pressed", "hover_pressed"] else Color("23282b")
		frame.border_color = Color("ceccb3") if action.button_pressed else Color("5b6265")
		action.add_theme_stylebox_override(state, frame)

func _style_collection(phone: bool, tablet: bool) -> void:
	get_node(^"Content/Caption/Title").add_theme_font_size_override("font_size", 20 if tablet else 25)
	get_node(^"Content/Caption/Count").add_theme_font_size_override("font_size", 17 if tablet else 20)
	for path in [^"Content/Pager/Previous", ^"Content/Pager/Next"]:
		get_node(path).add_theme_stylebox_override("normal", preload("res://rookframe/ui/theme/silkbound_plain.tres"))
		get_node(path).add_theme_stylebox_override("disabled", preload("res://rookframe/ui/theme/silkbound_plain.tres"))
	for path in [^"Content/Pager/Range", ^"Content/Pager/Indicator/Page"]:
		get_node(path).add_theme_font_size_override("font_size", 14 if tablet else 15 if phone else 18)
	get_node(^"Content/Pager/Indicator/PhoneCount").add_theme_font_size_override("font_size", 12)
	for path in [^"Content/Pager/Previous", ^"Content/Pager/Next"]:
		get_node(path).add_theme_font_size_override("font_size", 28)
	_title_font.spacing_top = -1 if phone or tablet else -2
	_title_font.spacing_bottom = -1 if phone or tablet else -2
	_subtitle_font.spacing_top = -1
	_subtitle_font.spacing_bottom = 0 if phone or tablet else -1

func _style_record(title: Label, subtitle: Label, value: Label, phone: bool, tablet: bool, inventory: bool, entry: Dictionary) -> void:
	var title_size := 19 if phone else (20 if inventory else 19) if tablet else 23 if inventory else 24
	var subtitle_size := (15 if inventory else 14) if phone else (16 if inventory else 14) if tablet else 17 if inventory else 18
	title.add_theme_font_override("font", _title_font)
	subtitle.add_theme_font_override("font", _subtitle_font)
	title.add_theme_font_size_override("font_size", title_size)
	subtitle.add_theme_font_size_override("font_size", subtitle_size)
	value.add_theme_font_size_override("font_size", 13 if phone and entry.get("phone_value_meta", false) else 20 if phone else 19 if tablet else 25)

func _style_action_type(action: Button, phone: bool, tablet: bool) -> void:
	action.add_theme_font_size_override("font_size", 17 if phone or tablet else 19)

func _style_grid(grid: GridContainer, phone: bool, tablet: bool) -> void:
	var inset := 0 if phone else 4 if get_viewport_rect().size.x <= 1300 else 10
	add_theme_constant_override("margin_left", inset)
	add_theme_constant_override("margin_right", inset)
	add_theme_constant_override("margin_top", 11 if divider_top and not phone else 0)
	grid.add_theme_constant_override("v_separation", 4 if phone or tablet else 6)
	grid.add_theme_constant_override("h_separation", 12 if tablet else 24)
	grid.offset_top = 4 if phone else 6 if tablet else 12

func _style_record_spacing(row: Control, row_inset: MarginContainer, phone: bool, tablet: bool, inventory: bool) -> void:
	var gap := 8 if phone or tablet else 12 if inventory else 18
	row.get_node(^"Details/Inset/Row").add_theme_constant_override("separation", gap)
	var px := 4 if phone else 2 if tablet else 6 if inventory else 8
	var py := 4 if phone else 6 if tablet else 10
	var text_gap := 3 if phone or tablet else 4
	row.get_node(^"Details/Inset/Row/Copy").add_theme_constant_override("separation", text_gap)
	for edge in ["left", "right", "top", "bottom"]:
		row_inset.add_theme_constant_override("margin_" + edge, px if edge in ["left", "right"] else py)
