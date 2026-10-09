@tool
extends VBoxContainer
## Measured whole-row pagination with a retained selected row.
signal selected(id: String)
const ROW = preload("res://rookframe/ui/_internal/data/task_choice.tscn")
@export var silkbound := false
var _entries: Array[Dictionary] = []
var _rows: Array[Button] = []
var _selected := ""
var _page := 0
var _pages: Array[Vector2i] = [Vector2i.ZERO]
var _pending := false
var _reveal := false
@export var empty_text := "No entries in this group.":
	set(value):
		empty_text = value
		_queue_fit()
## The sheet collection frame retains its range and page controls even on one page.
@export var framed_collection := false:
	set(value):
		framed_collection = value
		_queue_fit()
@export_enum("Ordinary", "Wide", "Inventory") var collection_layout := 0:
	set(value):
		collection_layout = value
		_queue_fit()
@export_range(1, 2) var columns := 1:
	set(value):
		columns = value
		_queue_fit()

## Package-owned footer content shares the stock collection pager row.
func get_footer_slot() -> HBoxContainer:
	return get_node(^"Pager/FooterContent")

func capture_state() -> Dictionary:
	return {"page": _page}

func restore_state(state: Dictionary) -> void:
	_page = maxi(0, int(state.get("page", 0)))
	_reveal = false
	_queue_fit()

## Return keyboard focus to an entry after its detail task closes.
func focus_entry(id: String) -> bool:
	if not is_visible_in_tree():
		return false
	for index in range(_entries.size()):
		if str(_entries[index].get("id", "")) == id and index < _rows.size():
			_page = _page_for_entry(index)
			_show_page()
			_rows[index].grab_focus()
			return true
	return false

func _enter_tree() -> void:
	_queue_fit()

func _ready() -> void:
	if framed_collection:
		var pager := get_node(^"Pager")
		pager.move_child(get_node(^"Pager/FooterContent"), 0)
		pager.move_child(get_node(^"Pager/Range"), 1)
		pager.move_child(get_node(^"Pager/Indicator"), 3)
		get_node(^"Pager/Range").horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		get_node(^"Pager/Indicator/Page").show()
		get_node(^"Pager/Previous").text = "‹"
		get_node(^"Pager/Next").text = "›"
		get_node(^"Pager/Previous").accessibility_name = "Previous page"
		get_node(^"Pager/Next").accessibility_name = "Next page"
		get_node(^"Pager/Previous").tooltip_text = "Previous page"
		get_node(^"Pager/Next").tooltip_text = "Next page"
	get_node(^"Pager/Previous").pressed.connect(func(): _page -= 1; _show_page())
	get_node(^"Pager/Next").pressed.connect(func(): _page += 1; _show_page())
	get_node(^"Pager/FooterContent").child_entered_tree.connect(func(_child: Node): _queue_fit())
	get_node(^"Pager/FooterContent").child_exiting_tree.connect(func(_child: Node): _queue_fit())
	resized.connect(_queue_fit)
	_queue_fit()

func configure(entries: Array[Dictionary], selected_id: String, caption: String = "", count: String = "") -> void:
	var same_ids := entries.size() == _entries.size()
	if same_ids:
		for index in entries.size():
			if str(entries[index].id) != str(_entries[index].id):
				same_ids = false
				break
	_reveal = _selected != selected_id or not same_ids
	_selected = selected_id
	_entries = entries.duplicate(true)
	if not same_ids:
		for row in _rows:
			row.get_parent().remove_child(row)
			row.queue_free()
		_rows.clear()
		for entry in entries:
			var row := ROW.instantiate() as Button
			row.pressed.connect(func(): selected.emit(str(entry.id)))
			get_node(^"Area/Rows").add_child(row)
			_rows.append(row)
	for index in _rows.size():
		var entry := entries[index]
		var row := _rows[index]
		row.get_node(^"Inset/Row/Copy/Title").text = str(entry.get("title", ""))
		row.get_node(^"Inset/Row/Copy/Subtitle").text = str(entry.get("subtitle", ""))
		row.get_node(^"Inset/Row/Copy/Subtitle").visible = not str(entry.get("subtitle", "")).is_empty()
		row.get_node(^"Inset/Row/Value").text = str(entry.get("value", ""))
		row.get_node(^"Inset/Row/Icon").texture = entry.get("icon")
		row.get_node(^"Inset/Row/Icon").self_modulate = Color("d0be8e") if framed_collection or str(entry.id) == selected_id else Color("aebabe")
		var pending := bool(entry.get("pending", false))
		row.get_node(^"Inset/Row/Value").add_theme_font_size_override("font_size", 12 if pending else 20)
		row.get_node(^"Inset/Row/Value").add_theme_color_override("font_color", Color("aebabe") if pending else Color("d0be8e"))
		row.set_pressed_no_signal(str(entry.id) == selected_id)
		row.accessibility_name = "%s. %s. %s" % [entry.get("title", ""), entry.get("subtitle", ""), entry.get("value", "")]
	get_node(^"Caption/Title").text = caption
	get_node(^"Caption/Count").text = count
	_queue_fit()

func _queue_fit() -> void:
	if not is_inside_tree() or not is_node_ready() or _pending:
		return
	_pending = true
	_fit.call_deferred()

func _fit() -> void:
	if not is_inside_tree():
		_pending = false
		return
	var phone := get_viewport_rect().size.y <= 560
	var tablet := get_viewport_rect().size.x <= 1150 and not phone
	var height := 48 if phone else 59 if tablet and collection_layout == 1 else 55 if tablet else 65 if collection_layout == 1 else 59
	if not framed_collection:
		height = 44 if phone else 56 if tablet else 68
		if tablet:
			var titles_only := true
			for entry in _entries:
				titles_only = titles_only and str(entry.get("subtitle", "")).is_empty()
			if titles_only:
				height = 48
	var grid := get_node(^"Area/Rows") as GridContainer
	var inset := 0 if phone or not framed_collection else 5 if tablet else 8
	var vertical_inset := 8 if framed_collection and not phone else 0
	grid.offset_left = inset
	grid.offset_right = -inset
	grid.offset_top = vertical_inset
	grid.columns = columns
	grid.add_theme_constant_override("h_separation", (12 if phone or tablet else 28) if framed_collection else 8)
	grid.add_theme_constant_override("v_separation", 2 if phone and not framed_collection else 4)
	get_node(^"Caption").visible = not (framed_collection and phone)
	get_node(^"Pager/Range").visible = not (framed_collection and phone)
	get_node(^"Pager/FooterContent").visible = get_node(^"Pager/FooterContent").get_child_count() > 0
	get_node(^"Area/Empty").visible = _entries.is_empty()
	get_node(^"Area/Empty").text = empty_text
	get_node(^"Caption").custom_minimum_size.y = (32 if tablet else 39) if framed_collection else 28 if phone else 42
	get_node(^"Pager").custom_minimum_size.y = 44 if framed_collection else 48 if phone else 53
	get_node(^"Caption/Title").add_theme_font_size_override("font_size", (13 if tablet else 16) if framed_collection else 10 if phone else 12)
	get_node(^"Caption/Count").add_theme_font_size_override("font_size", (14 if tablet else 18) if framed_collection else 10 if phone else 12)
	get_node(^"Pager/Range").add_theme_font_size_override("font_size", 10 if phone and not framed_collection else 12)
	get_node(^"Pager/Indicator/Page").add_theme_font_size_override("font_size", 15 if phone else 14)
	get_node(^"Pager/Indicator/PhoneCount").visible = framed_collection and phone
	if framed_collection:
		get_node(^"Caption/Title").add_theme_color_override("font_color", Color("d9ae94"))
		for label in [^"Caption/Title", ^"Caption/Count", ^"Pager/Range"]:
			get_node(label).add_theme_stylebox_override("normal", preload("res://rookframe/ui/_internal/data/collection_label.tres"))
	for button in [^"Pager/Previous", ^"Pager/Next"]:
		get_node(button).theme_type_variation = "TaskGlyphButton" if framed_collection else "TaskButton"
		get_node(button).add_theme_font_size_override("font_size", (25 if phone else 24) if framed_collection else 12 if phone else 15)
	for row in _rows:
		row.custom_minimum_size.y = height
		var title := row.get_node(^"Inset/Row/Copy/Title") as Label
		if framed_collection:
			title.add_theme_font_override("font", preload("res://rookframe/ui/_internal/data/collection_title.tres"))
			title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			title.max_lines_visible = 2
			title.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		title.add_theme_font_size_override("font_size", (16 if phone and collection_layout == 2 else 17 if phone else 15 if tablet else 19) if framed_collection else 14 if phone and columns == 2 else 15 if phone else 16 if tablet else 20)
		row.get_node(^"Inset/Row/Copy/Subtitle").add_theme_font_size_override("font_size", (13 if phone else 12 if tablet else 14) if framed_collection else 10 if phone else 11 if tablet else 12)
		row.get_node(^"Inset/Row/Icon").custom_minimum_size = (Vector2(29, 29) if phone or tablet else Vector2(38, 38)) if framed_collection else Vector2(23, 23) if phone else Vector2(26, 26) if tablet else Vector2(30, 30)
		row.get_node(^"Inset/Row").add_theme_constant_override("separation", (8 if phone else 7 if tablet else 12) if framed_collection else 8 if phone else 10 if tablet else 14)
		for edge in ["left", "right", "top", "bottom"]:
			var horizontal: bool = edge in ["left", "right"]
			var padding := (6 if horizontal else 4) if phone else (6 if horizontal else 7) if tablet else (12 if horizontal else 10) if collection_layout == 2 else (10 if horizontal else 9)
			if not framed_collection:
				padding = (9 if horizontal else 4) if phone else (10 if horizontal else 8) if tablet else (16 if horizontal else 9)
			row.get_node(^"Inset").add_theme_constant_override("margin_" + edge, padding)
		var value := row.get_node(^"Inset/Row/Value") as Label
		value.size_flags_horizontal = Control.SIZE_FILL if framed_collection or columns > 1 or tablet else Control.SIZE_EXPAND_FILL
		if framed_collection:
			value.add_theme_font_override("font", get_theme_font("font"))
		var pending := bool(_entries[_rows.find(row)].get("pending", false))
		value.add_theme_font_size_override("font_size", 12 if pending else (18 if phone else (14 if collection_layout == 2 else 16) if tablet else 18 if collection_layout == 2 else 20) if framed_collection else 17 if tablet else 20)
		var measured := value.get_theme_font("font").get_string_size(value.text, HORIZONTAL_ALIGNMENT_LEFT, -1, value.get_theme_font_size("font_size")).x
		value.custom_minimum_size.x = minf(ceilf(measured), (size.x - inset * 2) / columns * 0.3) if framed_collection else minf(ceilf(measured), size.x * 0.3) if tablet else 14 if columns > 1 else 0

	height = _fit_silkbound()
	# The authored row has an inset Control, so include its effective child
	# minimum as well as the framed Button's minimum (ADR-0017).
	var heights: Array[float] = []
	for row in _rows:
		var row_height := float(height)
		if framed_collection:
			var title := row.get_node(^"Inset/Row/Copy/Title") as Label
			var copy := row.get_node(^"Inset/Row/Copy") as VBoxContainer
			var row_inset := row.get_node(^"Inset") as MarginContainer
			var row_box := row.get_node(^"Inset/Row") as HBoxContainer
			var width: float = (size.x - inset * 2 - (columns - 1) * grid.get_theme_constant("h_separation")) / columns - row_inset.get_theme_constant("margin_left") - row_inset.get_theme_constant("margin_right") - row.get_node(^"Inset/Row/Icon").get_combined_minimum_size().x - row.get_node(^"Inset/Row/Value").get_combined_minimum_size().x - row_box.get_theme_constant("separation") * 2
			var title_height := title.get_theme_font("font").get_multiline_string_size(title.text, HORIZONTAL_ALIGNMENT_LEFT, maxf(1.0, width), title.get_theme_font_size("font_size"), title.max_lines_visible, TextServer.BREAK_MANDATORY | TextServer.BREAK_WORD_BOUND | TextServer.BREAK_ADAPTIVE).y
			title_height += title.get_theme_constant("line_spacing") * (title.max_lines_visible - 1)
			var subtitle_height: float = row.get_node(^"Inset/Row/Copy/Subtitle").get_combined_minimum_size().y if row.get_node(^"Inset/Row/Copy/Subtitle").visible else 0.0
			row_height = maxf(row_height, ceilf(title_height + subtitle_height + (copy.get_theme_constant("separation") if subtitle_height > 0 else 0) + row_inset.get_theme_constant("margin_top") + row_inset.get_theme_constant("margin_bottom")))
		row_height = maxf(row_height, maxf(row.get_combined_minimum_size().y, row.get_node(^"Inset").get_combined_minimum_size().y))
		row.custom_minimum_size.y = row_height
		heights.append(row_height)
	# One entry never enlarges the owning window. The authored frame reserves
	# a native 44px target; page ranges use only the rows on each page.
	get_node(^"Area").custom_minimum_size.y = 44
	var available: float = size.y - (get_node(^"Caption").get_combined_minimum_size().y if get_node(^"Caption").visible else 0.0)
	available -= vertical_inset * 2
	var gap := grid.get_theme_constant("v_separation")
	_fit_pages(heights, available, gap)
	var pager_visible := framed_collection or _pages.size() > 1
	if pager_visible:
		_fit_pages(heights, available - get_node(^"Pager").get_combined_minimum_size().y, gap)
	get_node(^"Pager").visible = pager_visible
	if _reveal:
		for index in _entries.size():
			if str(_entries[index].id) == _selected:
				_page = _page_for_entry(index)
	_reveal = false
	_show_page()
	_pending = false
	queue_redraw()

func _fit_pages(heights: Array[float], available: float, gap: float) -> void:
	_pages.clear()
	var first := 0
	var used := 0.0
	for index in range(0, heights.size(), columns):
		var row_height := heights[index]
		for column in range(1, mini(columns, heights.size() - index)):
			row_height = maxf(row_height, heights[index + column])
		if index > first and used + gap + row_height > available:
			_pages.append(Vector2i(first, index))
			first = index
			used = 0
		used += (gap if index > first else 0.0) + row_height
	_pages.append(Vector2i(first, heights.size()))

func _page_for_entry(index: int) -> int:
	for page in range(_pages.size()):
		if index >= _pages[page].x and index < _pages[page].y:
			return page
	return 0

func _draw() -> void:
	if framed_collection:
		draw_style_box(preload("res://rookframe/ui/_internal/data/collection_frame.tres"), Rect2(Vector2.ZERO, size))
		if get_node(^"Caption").visible:
			draw_style_box(preload("res://rookframe/ui/_internal/data/collection_caption.tres"), Rect2(Vector2.ZERO, Vector2(size.x, get_node(^"Caption").size.y)))
	draw_line(Vector2(0, 0.5), Vector2(size.x, 0.5), Color("3e4346"))
	var pager := get_node_or_null(^"Pager") as Control
	if pager != null and pager.visible:
		draw_line(Vector2(0, pager.position.y), Vector2(size.x, pager.position.y), Color("3e4346"))

func _show_page() -> void:
	var pages := _pages.size()
	_page = clampi(_page, 0, pages - 1)
	for index in _rows.size():
		_rows[index].visible = index >= _pages[_page].x and index < _pages[_page].y
	get_node(^"Pager/Previous").disabled = _page == 0
	get_node(^"Pager/Next").disabled = _page == pages - 1
	get_node(^"Pager/Indicator/Page").text = "%d / %d" % [_page + 1, pages]
	var range_format := "%d–%d\u2002of\u2002%d" if silkbound else "%d–%d of %d"
	var range_text := range_format % [_pages[_page].x + 1, _pages[_page].y, _rows.size()] if not _rows.is_empty() else "0 entries"
	get_node(^"Pager/Range").text = range_text
	if framed_collection and get_viewport_rect().size.y <= 560:
		get_node(^"Pager/Indicator/PhoneCount").text = range_text


func _fit_silkbound() -> int:
	var phone := get_viewport_rect().size.y <= 560 or get_viewport_rect().size.x <= 740
	var tablet := get_viewport_rect().size.x <= 1300 and not phone
	theme = preload("res://rookframe/ui/theme/silkbound_theme.tres")
	var titles_only := true
	for entry in _entries:
		titles_only = titles_only and str(entry.get("subtitle", "")).is_empty()
	var height := 44 if phone else (48 if titles_only else 52) if tablet else 68
	get_node(^"Caption").custom_minimum_size.y = 22 if phone else (32 if titles_only else 36) if tablet else 44
	for path in [^"Caption/Title", ^"Caption/Count"]:
		get_node(path).add_theme_font_override("font", preload("res://rookframe/ui/theme/silkbound_regular.tres"))
		get_node(path).add_theme_font_size_override("font_size", 15 if phone else 16 if tablet else 18)
	get_node(^"Caption/Title").add_theme_color_override("font_color", Color("aebabe"))
	get_node(^"Caption/Count").add_theme_color_override("font_color", Color("d9ae94"))
	get_node(^"Pager").custom_minimum_size.y = 53
	get_node(^"Pager/Range").add_theme_font_size_override("font_size", 15 if phone else 17)
	get_node(^"Pager/Range").add_theme_color_override("font_color", Color("aebabe"))
	for key in ["Previous", "Next"]:
		var action := get_node("Pager/" + key) as Button
		action.theme_type_variation = "WizardButton"
		action.text = ""
		action.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		action.icon = preload("res://rookframe/ui/icons/chevron-left.svg") if key == "Previous" else preload("res://rookframe/ui/icons/chevron-right.svg")
		action.expand_icon = true
		action.accessibility_name = "Previous page" if key == "Previous" else "Next page"
		action.tooltip_text = action.accessibility_name
		for state in ["normal", "hover", "pressed", "disabled"]:
			var box := action.get_theme_stylebox(state).duplicate() as StyleBoxFlat
			box.content_margin_left = 0
			box.content_margin_right = 0
			action.add_theme_stylebox_override(state, box)
	for index in _rows.size():
		var row := _rows[index]
		var selected := str(_entries[index].id) == _selected
		var foreground := Color("151719") if selected else Color("e7e7dd")
		row.theme_type_variation = "WizardChoice"
		row.custom_minimum_size.y = height
		row.get_node(^"Inset/Row/Icon").self_modulate = Color("151719") if selected else Color("d0be8e")
		row.get_node(^"Inset/Row/Icon").custom_minimum_size = Vector2(24,24) if phone or tablet else Vector2(28,28)
		for label in [^"Inset/Row/Copy/Title", ^"Inset/Row/Value"]:
			row.get_node(label).add_theme_font_override("font", preload("res://rookframe/ui/theme/silkbound_medium.tres"))
			row.get_node(label).add_theme_color_override("font_color", foreground)
		row.get_node(^"Inset/Row/Copy/Title").add_theme_font_size_override("font_size", 19 if phone else 20 if tablet else 24)
		row.get_node(^"Inset/Row/Copy/Subtitle").add_theme_font_size_override("font_size", 14 if phone else 15 if tablet else 18)
		row.get_node(^"Inset/Row/Copy/Subtitle").add_theme_color_override("font_color", Color("151719") if selected else Color("aebabe"))
		row.get_node(^"Inset/Row/Copy").add_theme_constant_override("separation", 2 if phone or tablet else 4)
		row.get_node(^"Inset/Row").add_theme_constant_override("separation", 8 if phone or tablet else 12)
		var pending := bool(_entries[index].get("pending", false))
		var value := row.get_node(^"Inset/Row/Value") as Label
		value.add_theme_font_size_override("font_size", (15 if phone else 16 if tablet else 18) if pending else 20 if phone or tablet else 24)
		var measured := value.get_theme_font("font").get_string_size(value.text,HORIZONTAL_ALIGNMENT_LEFT,-1,value.get_theme_font_size("font_size")).x
		value.custom_minimum_size.x = minf(ceilf(measured),size.x / columns * 0.3)
		value.size_flags_horizontal = Control.SIZE_FILL
		for edge in ["left","right","top","bottom"]:
			row.get_node(^"Inset").add_theme_constant_override("margin_"+edge,(8 if phone or tablet else 12) if edge in ["left","right"] else 2 if phone or tablet else 8)
		preload("res://rookframe/ui/theme/silkbound_line_height.gd").apply(row.get_node(^"Inset/Row/Copy/Title"),1.1 if phone else 1.15)
		preload("res://rookframe/ui/theme/silkbound_line_height.gd").apply(row.get_node(^"Inset/Row/Copy/Subtitle"),1.1 if phone else 1.2)
		preload("res://rookframe/ui/theme/silkbound_line_height.gd").apply(value,1.15)
	return height
