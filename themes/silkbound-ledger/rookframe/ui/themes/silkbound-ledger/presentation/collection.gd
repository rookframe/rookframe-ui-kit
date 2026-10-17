@tool
extends RefCounted
const Appearance = preload("res://rookframe/ui/_internal/presentation/appearance.gd")


const MEDIUM = preload("res://rookframe/ui/theme/silkbound_medium.tres")
const REGULAR = preload("res://rookframe/ui/theme/silkbound_regular.tres")
var _title_font: FontVariation = MEDIUM.duplicate()
var _subtitle_font: FontVariation = REGULAR.duplicate()

func _draw(control) -> void:
	if not control.is_node_ready():
		return
	if control.divider_top and control.get_node(^"Content/Caption").visible:
		control.draw_line(Vector2.ZERO, Vector2(control.size.x, 0), Color("3e4346"))
	if control.get_node(^"Content/Caption").visible:
		control.draw_line(Vector2(0, control.get_node(^"Content/Caption").size.y + control.get_theme_constant("margin_top")), Vector2(control.size.x, control.get_node(^"Content/Caption").size.y + control.get_theme_constant("margin_top")), Color("5b6265"))
	var pager = control.get_node(^"Content/Pager") as Control
	if not pager.visible:
		return
	control.draw_line(Vector2(control.get_theme_constant("margin_left"), pager.position.y + control.get_theme_constant("margin_top")), Vector2(control.size.x - control.get_theme_constant("margin_right"), pager.position.y + control.get_theme_constant("margin_top")), Color("3e4346"))

func _style_action(control, action: Button) -> void:
	for state in ["normal", "hover", "pressed", "hover_pressed", "disabled"]:
		var frame = action.get_theme_stylebox(state).duplicate() as StyleBoxFlat
		Appearance.write(frame, ^"content_margin_left", 8 if action.icon != null else 10)
		Appearance.write(frame, ^"content_margin_right", frame.content_margin_left)
		Appearance.write(frame, ^"content_margin_top", 8 if action.icon != null else 6)
		Appearance.write(frame, ^"content_margin_bottom", frame.content_margin_top)
		Appearance.write(frame, ^"bg_color", Color("ceccb3") if action.button_pressed else Color("343d41") if state in ["hover", "pressed", "hover_pressed"] else Color("23282b"))
		Appearance.write(frame, ^"border_color", Color("ceccb3") if action.button_pressed else Color("5b6265"))
		Appearance.override_item(action, "styles", state, frame)

func _style_collection(control, phone: bool, tablet: bool) -> void:
	Appearance.override_item(control.get_node(^"Content/Caption/Title"), "font_sizes", "font_size", 20 if tablet else 25)
	Appearance.override_item(control.get_node(^"Content/Caption/Count"), "font_sizes", "font_size", 17 if tablet else 20)
	for path in [^"Content/Pager/Previous", ^"Content/Pager/Next"]:
		Appearance.override_item(control.get_node(path), "styles", "normal", preload("res://rookframe/ui/theme/silkbound_plain.tres"))
		Appearance.override_item(control.get_node(path), "styles", "disabled", preload("res://rookframe/ui/theme/silkbound_plain.tres"))
	for path in [^"Content/Pager/Range", ^"Content/Pager/Indicator/Page"]:
		Appearance.override_item(control.get_node(path), "font_sizes", "font_size", 14 if tablet else 15 if phone else 18)
	Appearance.override_item(control.get_node(^"Content/Pager/Indicator/PhoneCount"), "font_sizes", "font_size", 12)
	for path in [^"Content/Pager/Previous", ^"Content/Pager/Next"]:
		Appearance.override_item(control.get_node(path), "font_sizes", "font_size", 28)
	Appearance.write(_title_font, ^"spacing_top", -1 if phone or tablet else -2)
	Appearance.write(_title_font, ^"spacing_bottom", -1 if phone or tablet else -2)
	Appearance.write(_subtitle_font, ^"spacing_top", -1)
	Appearance.write(_subtitle_font, ^"spacing_bottom", 0 if phone or tablet else -1)

func _style_record(control, title: Label, subtitle: Label, value: Label, phone: bool, tablet: bool, inventory: bool, entry: Dictionary) -> void:
	var title_size = 19 if phone else (20 if inventory else 19) if tablet else 23 if inventory else 24
	var subtitle_size = (15 if inventory else 14) if phone else (16 if inventory else 14) if tablet else 17 if inventory else 18
	Appearance.override_item(title, "fonts", "font", _title_font)
	Appearance.override_item(subtitle, "fonts", "font", _subtitle_font)
	Appearance.override_item(title, "font_sizes", "font_size", title_size)
	Appearance.override_item(subtitle, "font_sizes", "font_size", subtitle_size)
	Appearance.override_item(value, "font_sizes", "font_size", 13 if phone and entry.get("phone_value_meta", false) else 20 if phone else 19 if tablet else 25)

func _style_action_type(control, action: Button, phone: bool, tablet: bool) -> void:
	Appearance.override_item(action, "font_sizes", "font_size", 17 if phone or tablet else 19)

func _style_grid(control, grid: GridContainer, phone: bool, tablet: bool) -> void:
	var inset = 0 if phone else 4 if control.get_viewport_rect().size.x <= 1300 else 10
	Appearance.override_item(control, "constants", "margin_left", inset)
	Appearance.override_item(control, "constants", "margin_right", inset)
	Appearance.override_item(control, "constants", "margin_top", 11 if control.divider_top and not phone else 0)
	Appearance.override_item(grid, "constants", "v_separation", 4 if phone or tablet else 6)
	Appearance.override_item(grid, "constants", "h_separation", 12 if tablet else 24)
	Appearance.write(grid, ^"offset_top", 4 if phone else 6 if tablet else 12)

func _style_record_spacing(control, row: Control, row_inset: MarginContainer, phone: bool, tablet: bool, inventory: bool) -> void:
	var gap = 8 if phone or tablet else 12 if inventory else 18
	Appearance.override_item(row.get_node(^"Details/Inset/Row"), "constants", "separation", gap)
	var px = 4 if phone else 2 if tablet else 6 if inventory else 8
	var py = 4 if phone else 6 if tablet else 10
	var text_gap = 3 if phone or tablet else 4
	Appearance.override_item(row.get_node(^"Details/Inset/Row/Copy"), "constants", "separation", text_gap)
	for edge in ["left", "right", "top", "bottom"]:
		Appearance.override_item(row_inset, "constants", "margin_" + edge, px if edge in ["left", "right"] else py)
