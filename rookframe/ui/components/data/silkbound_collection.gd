@tool
extends MarginContainer
## Bounded Silkbound records with a distinct optional row action.
## The caller owns the records and all mutations; this Control owns only paging.
signal selected(id: String)
signal action_requested(id: String)
const ROW = preload("res://rookframe/ui/_internal/data/silkbound_collection_row.tscn")
@export var empty_text := "No entries in this group."
@export var framed_collection := true
@export var divider_top := false
@export_enum("Ordinary", "Wide", "Inventory") var collection_layout := 0
@export_range(1, 2) var columns := 1
var _entries: Array[Dictionary] = []
var _rows: Array[Control] = []
var _pages: Array[Vector2i] = [Vector2i.ZERO]
var _page := 0
var _pending := true
var _settle := 0
var _restore_focus: Control
const MEDIUM = preload("res://rookframe/ui/theme/silkbound_medium.tres")
const REGULAR = preload("res://rookframe/ui/theme/silkbound_regular.tres")
var _title_font: FontVariation
var _subtitle_font: FontVariation

func _ready() -> void:
	_title_font = MEDIUM.duplicate()
	_subtitle_font = REGULAR.duplicate()
	get_node(^"Content/Pager/Previous").pressed.connect(_turn.bind(-1))
	get_node(^"Content/Pager/Next").pressed.connect(_turn.bind(1))
	resized.connect(_queue_fit)
	get_node(^"Content/Area").resized.connect(_queue_fit)
	visibility_changed.connect(_queue_fit)
	get_node(^"Content/Pager/FooterContent").child_entered_tree.connect(_footer_changed)
	get_node(^"Content/Pager/FooterContent").child_exiting_tree.connect(_footer_changed)

func _footer_changed(_child: Node) -> void:
	_queue_fit()

func get_footer_slot() -> HBoxContainer:
	return get_node(^"Content/Pager/FooterContent")

func capture_state() -> Dictionary:
	return {"page": _page}

func restore_state(state: Dictionary) -> void:
	_page = maxi(0, int(state.get("page", 0)))
	_queue_fit()

func focus_entry(id: String) -> bool:
	if not is_visible_in_tree():
		return false
	for index in _entries.size():
		if str(_entries[index].id) == id:
			for page in _pages.size():
				if index >= _pages[page].x and index < _pages[page].y:
					_page = page
			_show_page()
			_rows[index].get_node(^"Details").grab_focus()
			return true
	return false

func configure(entries: Array[Dictionary], _selected_id: String, caption: String = "", count: String = "") -> void:
	var focused := get_viewport().gui_get_focus_owner()
	if focused != null and is_ancestor_of(focused):
		_restore_focus = focused
	var same := entries.size() == _entries.size()
	if same:
		for index in entries.size():
			if str(entries[index].id) != str(_entries[index].id):
				same = false
				break
	_entries = entries.duplicate(true)
	if not same:
		for row in _rows:
			row.get_parent().remove_child(row)
			row.queue_free()
		_rows.clear()
		for entry in _entries:
			var row := ROW.instantiate() as Control
			row.get_node(^"Details").pressed.connect(_select.bind(str(entry.id)))
			row.get_node(^"Action").pressed.connect(_act.bind(str(entry.id)))
			get_node(^"Content/Area/Rows").add_child(row)
			_rows.append(row)
	for index in _rows.size():
		var entry := _entries[index]
		var row := _rows[index]
		row.get_node(^"Details/Inset/Row/Copy/Title").text = str(entry.get("title", ""))
		row.get_node(^"Details/Inset/Row/Copy/Subtitle").text = str(entry.get("subtitle", ""))
		row.get_node(^"Details/Inset/Row/Copy/Subtitle").visible = not str(entry.get("subtitle", "")).is_empty()
		row.get_node(^"Details/Inset/Row/Value").text = str(entry.get("value", ""))
		row.get_node(^"Details/Inset/Row/Value").visible = not str(entry.get("value", "")).is_empty()
		row.get_node(^"Details/Inset/Row/Icon").texture = entry.get("icon")
		row.get_node(^"Details").accessibility_name = "%s. %s. %s" % [entry.get("title", ""), entry.get("subtitle", ""), entry.get("value", "")]
		var action := row.get_node(^"Action") as Button
		action.visible = entry.has("action")
		action.text = str(entry.get("action_text", ""))
		action.icon = entry.get("action_icon")
		action.disabled = bool(entry.get("action_disabled", false))
		action.tooltip_text = str(entry.get("action", ""))
		action.toggle_mode = entry.has("action_pressed")
		action.set_pressed_no_signal(bool(entry.get("action_pressed", false)))
		action.accessibility_name = action.tooltip_text
		action.theme_type_variation = &"SilkPrimaryIcon" if entry.get("action_pressed", false) else &"SilkIcon"
	get_node(^"Content/Caption/Title").text = caption
	get_node(^"Content/Caption/Count").text = count
	get_node(^"Content/Area/Empty").text = empty_text
	get_node(^"Content/Area/Empty").visible = entries.is_empty()
	_queue_fit()

func _select(id: String) -> void:
	selected.emit(id)

func _act(id: String) -> void:
	action_requested.emit(id)

func _queue_fit() -> void:
	_pending = true
	_settle = 2

func _process(_delta: float) -> void:
	if not _pending or not is_node_ready() or not is_visible_in_tree():
		return
	if _settle > 0:
		_settle -= 1
		return
	_pending = false
	_fit()

func _fit() -> void:
	var phone := get_viewport_rect().size.x <= 900
	var inset := 0 if phone else 4 if get_viewport_rect().size.x <= 1300 else 10
	add_theme_constant_override("margin_left", inset)
	add_theme_constant_override("margin_right", inset)
	add_theme_constant_override("margin_top", 11 if divider_top and not phone else 0)
	var tablet := get_viewport_rect().size.x <= 1300 and not phone
	var grid := get_node(^"Content/Area/Rows") as GridContainer
	grid.columns = 1 if phone else columns
	grid.add_theme_constant_override("v_separation", 4 if phone or tablet else 6)
	grid.add_theme_constant_override("h_separation", 12 if tablet else 24)
	grid.offset_top = 4 if phone else 6 if tablet else 12
	get_node(^"Content/Caption").visible = not phone
	get_node(^"Content/Caption").custom_minimum_size.y = 44 if tablet else 50
	get_node(^"Content/Caption/Title").add_theme_font_size_override("font_size", 20 if tablet else 25)
	get_node(^"Content/Caption/Count").add_theme_font_size_override("font_size", 17 if tablet else 20)
	get_node(^"Content/Pager/Range").visible = not phone
	for path in [^"Content/Pager/Previous", ^"Content/Pager/Next"]:
		get_node(path).add_theme_stylebox_override("normal", preload("res://rookframe/ui/theme/silkbound_plain.tres"))
		get_node(path).add_theme_stylebox_override("disabled", preload("res://rookframe/ui/theme/silkbound_plain.tres"))
	get_node(^"Content/Pager/FooterContent").visible = get_node(^"Content/Pager/FooterContent").get_child_count() > 0
	get_node(^"Content/Pager/Indicator/PhoneCount").visible = phone
	for path in [^"Content/Pager/Range", ^"Content/Pager/Indicator/Page"]:
		get_node(path).add_theme_font_size_override("font_size", 14 if tablet else 15 if phone else 18)
	get_node(^"Content/Pager/Indicator/PhoneCount").add_theme_font_size_override("font_size", 12)
	for path in [^"Content/Pager/Previous", ^"Content/Pager/Next"]:
		get_node(path).add_theme_font_size_override("font_size", 28)
	_title_font.spacing_top = -1 if phone or tablet else -2
	_title_font.spacing_bottom = -1 if phone or tablet else -2
	_subtitle_font.spacing_top = -1
	_subtitle_font.spacing_bottom = 0 if phone or tablet else -1
	var heights: Array[float] = []
	var width: float = (get_node(^"Content").size.x - (grid.columns - 1) * grid.get_theme_constant("h_separation")) / grid.columns
	for index in _rows.size():
		var row := _rows[index]
		var entry := _entries[index]
		var inventory := entry.has("action") or collection_layout == 2
		var button := row.get_node(^"Details") as Button
		var title := row.get_node(^"Details/Inset/Row/Copy/Title") as Label
		var subtitle := row.get_node(^"Details/Inset/Row/Copy/Subtitle") as Label
		var icon := row.get_node(^"Details/Inset/Row/Icon") as TextureRect
		var value := row.get_node(^"Details/Inset/Row/Value") as Label
		subtitle.text = str(entry.get("phone_subtitle", entry.get("subtitle", ""))) if phone else str(entry.get("subtitle", ""))
		subtitle.visible = not subtitle.text.is_empty()
		value.text = str(entry.get("phone_value", entry.get("value", ""))) if phone else str(entry.get("value", ""))
		value.visible = not value.text.is_empty()
		row.get_node(^"Details/Inset/Row/Arrow").visible = phone and not inventory
		var row_inset := row.get_node(^"Details/Inset") as MarginContainer
		var title_size := 19 if phone else (20 if inventory else 19) if tablet else 23 if inventory else 24
		var subtitle_size := (15 if inventory else 14) if phone else (16 if inventory else 14) if tablet else 17 if inventory else 18
		title.add_theme_font_override("font", _title_font)
		subtitle.add_theme_font_override("font", _subtitle_font)
		title.add_theme_font_size_override("font_size", title_size)
		subtitle.add_theme_font_size_override("font_size", subtitle_size)
		value.add_theme_font_size_override("font_size", 13 if phone and entry.get("phone_value_meta", false) else 20 if phone else 19 if tablet else 25)
		icon.custom_minimum_size = Vector2.ONE * (24 if phone or tablet else 30 if inventory else 34)
		var gap := 8 if phone or tablet else 12 if inventory else 18
		row.get_node(^"Details/Inset/Row").add_theme_constant_override("separation", gap)
		var px := 4 if phone else 2 if tablet else 6 if inventory else 8
		var py := 4 if phone else 6 if tablet else 10
		var text_gap := 3 if phone or tablet else 4
		row.get_node(^"Details/Inset/Row/Copy").add_theme_constant_override("separation", text_gap)
		for edge in ["left", "right", "top", "bottom"]:
			row_inset.add_theme_constant_override("margin_" + edge, px if edge in ["left", "right"] else py)
		var copy_width := width - 2 * px - icon.custom_minimum_size.x - gap - (16 if phone and not inventory else 0)
		if value.visible:
			copy_width -= value.get_minimum_size().x + gap
		if row.get_node(^"Action").visible:
			copy_width -= row.get_node(^"Action").get_combined_minimum_size().x + row.get_theme_constant("separation")
		var flags := TextServer.BREAK_MANDATORY | TextServer.BREAK_WORD_BOUND | TextServer.BREAK_ADAPTIVE
		var title_height := title.get_theme_font("font").get_multiline_string_size(title.text, HORIZONTAL_ALIGNMENT_LEFT, maxf(1, copy_width), title_size, -1, flags).y
		var subtitle_height := subtitle.get_theme_font("font").get_multiline_string_size(subtitle.text, HORIZONTAL_ALIGNMENT_LEFT, maxf(1, copy_width), subtitle_size, -1, flags).y if subtitle.visible else 0.0
		var height := maxf(54 if phone else 64 if inventory and tablet else 62 if tablet else 74, title_height + subtitle_height + 2 * py + (text_gap if subtitle.visible else 0) + (0 if phone else 1))
		button.custom_minimum_size.y = height
		heights.append(height)
	_pages.clear()
	var available: float = get_node(^"Content/Area").size.y - grid.offset_top * 2
	var start := 0
	var used := 0.0
	var row_gap := grid.get_theme_constant("v_separation")
	for index in range(0, heights.size(), grid.columns):
		var height := heights[index]
		for column in range(1, mini(grid.columns, heights.size() - index)):
			height = maxf(height, heights[index + column])
		if index > start and used + row_gap + height > available:
			_pages.append(Vector2i(start, index))
			start = index
			used = 0
		used += height + (row_gap if index > start else 0)
	_pages.append(Vector2i(start, heights.size()))
	_show_page()
	if is_instance_valid(_restore_focus) and _restore_focus.is_visible_in_tree():
		_restore_focus.grab_focus()
	_restore_focus = null
	queue_redraw()

func _show_page() -> void:
	_page = clampi(_page, 0, _pages.size() - 1)
	var bounds := _pages[_page]
	for index in _rows.size():
		_rows[index].visible = index >= bounds.x and index < bounds.y
	get_node(^"Content/Pager/Previous").disabled = _page == 0
	get_node(^"Content/Pager/Next").disabled = _page == _pages.size() - 1
	get_node(^"Content/Pager/Indicator/Page").text = "%d / %d" % [_page + 1, _pages.size()]
	var caption := "%d–%d of %d" % [bounds.x + 1, bounds.y, _rows.size()] if not _rows.is_empty() else "0 entries"
	get_node(^"Content/Pager/Range").text = caption
	get_node(^"Content/Pager/Indicator/PhoneCount").text = caption

func _turn(step: int) -> void:
	_page += step
	_show_page()

func _draw() -> void:
	if not is_node_ready():
		return
	if divider_top and get_node(^"Content/Caption").visible:
		draw_line(Vector2.ZERO, Vector2(size.x, 0), Color("3e4346"))
	if get_node(^"Content/Caption").visible:
		draw_line(Vector2(0, get_node(^"Content/Caption").size.y + get_theme_constant("margin_top")), Vector2(size.x, get_node(^"Content/Caption").size.y + get_theme_constant("margin_top")), Color("5b6265"))
	var pager := get_node(^"Content/Pager") as Control
	draw_line(Vector2(get_theme_constant("margin_left"), pager.position.y + get_theme_constant("margin_top")), Vector2(size.x - get_theme_constant("margin_right"), pager.position.y + get_theme_constant("margin_top")), Color("3e4346"))
