@tool
extends MarginContainer
const Appearance = preload("res://rookframe/ui/_internal/presentation/appearance.gd")
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
		_ink.finish()
		reveal_shader = value
		_ink.shader = value
@export var reduced_motion := false
## Bounded records with a distinct optional row action.
## The caller owns the records and all mutations; this Control owns only paging.
signal selected(id: String)
signal action_requested(id: String)
const ROW = preload("res://rookframe/ui/_internal/data/collection_row.tscn")
@export var row_scene: PackedScene = ROW
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
func _ready() -> void:
	get_node(^"Content/Pager/Previous").pressed.connect(_turn.bind(-1))
	get_node(^"Content/Pager/Next").pressed.connect(_turn.bind(1))
	resized.connect(_queue_fit)
	theme_changed.connect(_queue_fit)
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
	for index in _view_entries.size():
		if str(_view_entries[index].id) == id:
			for page in _pages.size():
				if index >= _pages[page].x and index < _pages[page].y:
					_page = page
			_show_page()
			_view_rows[index].get_node(^"Details").grab_focus()
			return true
	return false

func configure(entries: Array[Dictionary], _selected_id: String, caption: String = "", count: String = "") -> void:
	if not Records.valid(entries): return
	var focused := get_viewport().gui_get_focus_owner()
	_focus_position = Records.focused_index(_view_rows, focused)
	if _focus_position >= 0: _restore_focus = focused
	var retained := Records.reconcile(entries, _entries, _rows, get_node(^"Content/Area/Rows"), _create_row)
	_rows.assign(retained)
	_entries = entries.duplicate(true)
	_update_view()

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
		var details = row.get_node(^"Details")
		details.hint_title = str(entry.get("hint_title", entry.get("title", "")))
		details.hint_summary = str(entry.get("hint", ""))
		details.tooltip_text = details.hint_title + "\n" + details.hint_summary if not details.hint_summary.is_empty() else ""
		details.accessibility_description = details.hint_summary
		var action := row.get_node(^"Action") as Button
		action.visible = entry.has("action")
		action.text = str(entry.get("action_text", ""))
		action.icon = entry.get("action_icon")
		action.disabled = bool(entry.get("action_disabled", false))
		action.tooltip_text = str(entry.get("action", ""))
		action.toggle_mode = entry.has("action_pressed")
		action.set_pressed_no_signal(bool(entry.get("action_pressed", false)))
		action.accessibility_name = action.tooltip_text
		action.theme_type_variation = &"RookframePrimaryIcon" if entry.get("action_pressed", false) else &"RookframeIcon"
	get_node(^"Content/Caption/Title").text = caption
	get_node(^"Content/Caption/Count").text = count
	get_node(^"Content/Area/Empty").text = empty_text
	get_node(^"Content/Area/Empty").visible = entries.is_empty()
	_queue_fit()

func _create_row(id: String) -> Control:
	var row := row_scene.instantiate() as Control
	row.get_node(^"Details").pressed.connect(_select.bind(id))
	row.get_node(^"Action").pressed.connect(_act.bind(id))
	return row

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
	var phone := size.x <= 900
	var tablet := size.x <= 1300 and not phone
	var grid := get_node(^"Content/Area/Rows") as GridContainer
	grid.columns = 1 if phone else columns
	_style_grid(grid, phone, tablet)
	get_node(^"Content/Caption").visible = not phone
	get_node(^"Content/Caption").custom_minimum_size.y = 44 if tablet else 50
	get_node(^"Content/Pager/Range").visible = not phone
	get_node(^"Content/Pager/FooterContent").visible = get_node(^"Content/Pager/FooterContent").get_child_count() > 0
	get_node(^"Content/Pager/Indicator/PhoneCount").visible = phone
	_style_collection(phone, tablet)
	var heights: Array[float] = []
	var width: float = (get_node(^"Content").size.x - (grid.columns - 1) * grid.get_theme_constant("h_separation")) / grid.columns
	for index in _view_rows.size():
		var row: Control = _view_rows[index]
		var entry := _view_entries[index]
		var inventory := entry.has("action") or collection_layout == 2
		var action := row.get_node(^"Action") as Button
		action.custom_minimum_size = Vector2(44 if action.icon != null else 86, 44)
		_style_action_type(action, phone, tablet)
		action.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
		_style_action(action)
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
		_style_record(title, subtitle, value, phone, tablet, inventory, entry)
		var title_size := title.get_theme_font_size("font_size")
		var subtitle_size := subtitle.get_theme_font_size("font_size")
		icon.custom_minimum_size = Vector2.ONE * (24 if phone or tablet else 30 if inventory else 34)
		_style_record_spacing(row, row_inset, phone, tablet, inventory)
		var gap: int = row.get_node(^"Details/Inset/Row").get_theme_constant("separation")
		var px := row_inset.get_theme_constant("margin_left")
		var py := row_inset.get_theme_constant("margin_top")
		var text_gap: int = row.get_node(^"Details/Inset/Row/Copy").get_theme_constant("separation")
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
	# Stock shrink sizing: sections without vertical EXPAND finish immediately
	# after their records. Expanded collections still paginate in their allocation.
	var natural_height := 0.0
	for index in range(0, heights.size(), grid.columns):
		var row_height := heights[index]
		for column in range(1, mini(grid.columns, heights.size() - index)):
			row_height = maxf(row_height, heights[index + column])
		natural_height += row_height + (grid.get_theme_constant("v_separation") if index > 0 else 0)
	var expanded := (size_flags_vertical & Control.SIZE_EXPAND) != 0
	var footer := get_node(^"Content/Pager/FooterContent").get_child_count() > 0
	var caption_height: float = get_node(^"Content/Caption").get_combined_minimum_size().y if not phone else 0.0
	var pager_height: float = get_node(^"Content/Pager").get_combined_minimum_size().y
	custom_minimum_size.y = 0 if expanded else caption_height + maxf(44, natural_height + grid.offset_top) + (pager_height if footer else 0.0) + get_theme_constant("margin_top")
	# Measure with the whole area first, so hiding a single-page footer cannot
	# oscillate around the page boundary on subsequent Container layouts.
	var available: float = get_node(^"Content").size.y - caption_height - grid.offset_top * (2 if expanded else 1) - (pager_height if footer else 0.0)
	_paginate(heights, available, grid)
	if _pages.size() > 1 and not footer:
		_paginate(heights, available - pager_height, grid)
	var focused_index := Records.focused_index(_view_rows, _restore_focus if is_instance_valid(_restore_focus) else get_viewport().gui_get_focus_owner())
	if focused_index >= 0: _page = Records.page_for(focused_index, _pages)
	elif _focus_position >= 0 and not _view_rows.is_empty(): _page = Records.page_for(mini(_focus_position, _view_rows.size() - 1), _pages)
	_show_page()
	_restore_record_focus()
	queue_redraw()

func _paginate(heights: Array[float], available: float, grid: GridContainer) -> void:
	_pages.clear()
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

func _show_page() -> void:
	var multiple := _pages.size() > 1
	var footer := get_node(^"Content/Pager/FooterContent").get_child_count() > 0
	get_node(^"Content/Pager").visible = multiple or footer
	for path in [^"Content/Pager/Previous", ^"Content/Pager/Next", ^"Content/Pager/Indicator"]:
		get_node(path).visible = multiple
	get_node(^"Content/Pager/Range").visible = multiple and size.x > 900
	_page = clampi(_page, 0, _pages.size() - 1)
	var bounds := _pages[_page]
	for row in _rows:
		if row not in _view_rows: row.hide()
	for index in _view_rows.size():
		_view_rows[index].visible = index >= bounds.x and index < bounds.y
	get_node(^"Content/Pager/Previous").disabled = _page == 0
	get_node(^"Content/Pager/Next").disabled = _page == _pages.size() - 1
	get_node(^"Content/Pager/Indicator/Page").text = "%d / %d" % [_page + 1, _pages.size()]
	var caption := "%d–%d of %d" % [bounds.x + 1, bounds.y, _view_rows.size()] if not _view_rows.is_empty() else tr("0 entries")
	get_node(^"Content/Pager/Range").text = caption
	get_node(^"Content/Pager/Indicator/PhoneCount").text = caption

func _turn(step: int) -> void:
	_page += step
	_show_page()
	_ink.play(get_node(^"Content/Area"), reduced_motion)

func _draw() -> void:
	if Appearance.has_hook(self, &"_draw"):
		Appearance.invoke(self, &"_draw", [])
		return
	pass

func _exit_tree() -> void:
	_ink.finish()

func _style_action(action: Button) -> void:
	if Appearance.has_hook(self, &"_style_action"):
		Appearance.invoke(self, &"_style_action", [action])
		return
	pass

func _style_collection(phone: bool, tablet: bool) -> void:
	if Appearance.has_hook(self, &"_style_collection"):
		Appearance.invoke(self, &"_style_collection", [phone, tablet])
		return
	pass

func _style_record(title: Label, subtitle: Label, value: Label, phone: bool, tablet: bool, inventory: bool, entry: Dictionary) -> void:
	if Appearance.has_hook(self, &"_style_record"):
		Appearance.invoke(self, &"_style_record", [title, subtitle, value, phone, tablet, inventory, entry])
		return
	pass

func _style_action_type(action: Button, phone: bool, tablet: bool) -> void:
	if Appearance.has_hook(self, &"_style_action_type"):
		Appearance.invoke(self, &"_style_action_type", [action, phone, tablet])
		return
	pass

func _style_grid(grid: GridContainer, phone: bool, tablet: bool) -> void:
	if Appearance.has_hook(self, &"_style_grid"):
		Appearance.invoke(self, &"_style_grid", [grid, phone, tablet])
		return
	pass

func _style_record_spacing(row: Control, row_inset: MarginContainer, phone: bool, tablet: bool, inventory: bool) -> void:
	if Appearance.has_hook(self, &"_style_record_spacing"):
		Appearance.invoke(self, &"_style_record_spacing", [row, row_inset, phone, tablet, inventory])
		return
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


func _enter_tree() -> void:
	preload("res://rookframe/ui/_internal/presentation/binding.gd").attach(self)
