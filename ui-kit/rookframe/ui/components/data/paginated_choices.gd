@tool
extends VBoxContainer
const Records = preload("res://rookframe/ui/_internal/interaction/records.gd")
const Focus = preload("res://rookframe/ui/_internal/interaction/focus.gd")
@export var focus_fallback: Control
var _view_entries: Array[Dictionary] = []
var _view_rows: Array = []
var _visible_ids: Variant = null
var _focus_position := -1

var _ink := preload("res://rookframe/ui/_internal/surfaces/content_reveal.gd").new()
@export var reveal_shader: Shader:
	set(value):
		reveal_shader = value
		_ink.shader = value
@export var reduced_motion := false
## Measured whole-row pagination with a retained selected row.
signal selected(id: String)
const ROW = preload("res://rookframe/ui/_internal/data/task_choice.tscn")
@export var row_scene: PackedScene = ROW
var _entries: Array[Dictionary] = []
var _rows: Array[Button] = []
var _selected := ""
var _restore_focus: Control
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
	for index in range(_view_entries.size()):
		if str(_view_entries[index].get("id", "")) == id and index < _view_rows.size():
			_page = _page_for_entry(index)
			_show_page()
			_view_rows[index].grab_focus()
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
	get_node(^"Pager/Previous").pressed.connect(func(): _page -= 1; _show_page(); _ink.play(get_node(^"Area"), reduced_motion))
	get_node(^"Pager/Next").pressed.connect(func(): _page += 1; _show_page(); _ink.play(get_node(^"Area"), reduced_motion))
	get_node(^"Pager/FooterContent").child_entered_tree.connect(func(_child: Node): _queue_fit())
	get_node(^"Pager/FooterContent").child_exiting_tree.connect(func(_child: Node): _queue_fit())
	resized.connect(_queue_fit)
	theme_changed.connect(_queue_fit)
	_queue_fit()

func configure(entries: Array[Dictionary], selected_id: String, caption: String = "", count: String = "") -> void:
	if not Records.valid(entries): return
	var focused := get_viewport().gui_get_focus_owner()
	_focus_position = Records.focused_index(_view_rows, focused)
	if _focus_position >= 0: _restore_focus = focused
	var retained := Records.reconcile(entries, _entries, _rows, get_node(^"Area/Rows"), _create_row)
	_rows.assign(retained)
	_reveal = _selected != selected_id
	_selected = selected_id
	_entries = entries.duplicate(true)
	_update_view()

	for index in _rows.size():
		var entry := entries[index]
		var row := _rows[index]
		row.get_node(^"Inset/Row/Copy/Title").text = str(entry.get("title", ""))
		row.get_node(^"Inset/Row/Copy/Subtitle").text = str(entry.get("subtitle", ""))
		row.get_node(^"Inset/Row/Copy/Subtitle").visible = not str(entry.get("subtitle", "")).is_empty()
		row.get_node(^"Inset/Row/Value").text = str(entry.get("value", ""))
		row.get_node(^"Inset/Row/Icon").texture = entry.get("icon")
		_style_entry(row, entry, selected_id)
		row.set_pressed_no_signal(str(entry.id) == selected_id)
		row.accessibility_name = "%s. %s. %s" % [entry.get("title", ""), entry.get("subtitle", ""), entry.get("value", "")]
	get_node(^"Caption/Title").text = caption
	get_node(^"Caption/Count").text = count
	_queue_fit()

func _create_row(id: String) -> Control:
	var row := row_scene.instantiate() as Button
	row.pressed.connect(func(): selected.emit(id))
	return row

func _queue_fit() -> void:
	if not is_inside_tree() or not is_node_ready() or _pending:
		return
	_pending = true
	_fit.call_deferred()

func _fit() -> void:
	if not is_inside_tree():
		_pending = false
		return
	var metrics := _arrange_rows()
	var height: int = metrics.x
	var inset: float = metrics.y
	var vertical_inset: float = metrics.z
	var grid := get_node(^"Area/Rows") as GridContainer
	# The authored row has an inset Control, so include its effective child
	# minimum as well as the framed Button's minimum (ADR-0017).
	var heights: Array[float] = []
	for row in _view_rows:
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
		for index in _view_entries.size():
			if str(_view_entries[index].id) == _selected:
				_page = _page_for_entry(index)
	_reveal = false
	var focused_index := Records.focused_index(_view_rows, _restore_focus if is_instance_valid(_restore_focus) else get_viewport().gui_get_focus_owner())
	if focused_index >= 0: _page = Records.page_for(focused_index, _pages)
	elif _focus_position >= 0 and not _view_rows.is_empty(): _page = Records.page_for(mini(_focus_position, _view_rows.size() - 1), _pages)
	_show_page()
	_pending = false
	_restore_record_focus()
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
	pass

func _show_page() -> void:
	var pages := _pages.size()
	_page = clampi(_page, 0, pages - 1)
	for row in _rows:
		if row not in _view_rows: row.hide()
	for index in _view_rows.size():
		_view_rows[index].visible = index >= _pages[_page].x and index < _pages[_page].y
	get_node(^"Pager/Previous").disabled = _page == 0
	get_node(^"Pager/Next").disabled = _page == pages - 1
	get_node(^"Pager/Indicator/Page").text = "%d / %d" % [_page + 1, pages]
	var range_format := _range_format()
	var range_text := range_format % [_pages[_page].x + 1, _pages[_page].y, _view_rows.size()] if not _view_rows.is_empty() else tr("0 entries")
	get_node(^"Pager/Range").text = range_text
	if framed_collection and get_viewport_rect().size.y <= 560:
		get_node(^"Pager/Indicator/PhoneCount").text = range_text


func _range_format() -> String:
	return "%d–%d of %d"

func _exit_tree() -> void:
	_ink.finish()

func _arrange_rows() -> Vector3:
	var grid := get_node(^"Area/Rows") as GridContainer
	grid.columns = columns
	get_node(^"Pager/FooterContent").visible = get_node(^"Pager/FooterContent").get_child_count() > 0
	get_node(^"Area/Empty").visible = _view_entries.is_empty()
	get_node(^"Area/Empty").text = empty_text
	return Vector3(44, 0, 0)

func _style_entry(row: Control, entry: Dictionary, selected_id: String) -> void:
	pass

## Filter the view without replacing authoritative records or domain selection.
func set_visible_ids(ids: PackedStringArray) -> bool:
	var known: Dictionary = {}
	for entry in _entries: known[entry.id] = true
	var seen: Dictionary = {}
	for id in ids:
		if seen.has(id) or not known.has(id): return false
		seen[id] = true
	_remember_view_focus()
	_visible_ids = seen
	_update_view()
	_queue_fit()
	return true

func reset_filter() -> void:
	_remember_view_focus()
	_visible_ids = null
	_update_view()
	_queue_fit()

func _update_view() -> void:
	_view_entries.clear()
	_view_rows.clear()
	for index in _entries.size():
		if _visible_ids == null or _visible_ids.has(_entries[index].id):
			_view_entries.append(_entries[index])
			_view_rows.append(_rows[index])

func _restore_record_focus() -> void:
	if is_instance_valid(_restore_focus) and Focus.eligible(_restore_focus):
		Focus.give(_restore_focus)
	elif _focus_position >= 0:
		Focus.restore(_view_rows, _focus_position, focus_fallback)
	_restore_focus = null
	_focus_position = -1

func _remember_view_focus() -> void:
	var focused := get_viewport().gui_get_focus_owner()
	_focus_position = Records.focused_index(_view_rows, focused)
	_restore_focus = focused if _focus_position >= 0 else null
