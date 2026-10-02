@tool
extends VBoxContainer
## Measured whole-row pagination with a retained selected row.
signal selected(id: String)
const ROW = preload("res://rookframe/ui/_internal/data/task_choice.tscn")
var _entries: Array[Dictionary] = []
var _rows: Array[Button] = []
var _selected := ""
var _page := 0
var _capacity := 1
var _pending := false
var _reveal := false
@export_range(1, 2) var columns := 1:
	set(value):
		columns = value
		_queue_fit()

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
			_page = index / _capacity
			_show_page()
			_rows[index].grab_focus()
			return true
	return false

func _ready() -> void:
	get_node(^"Pager/Previous").pressed.connect(func(): _page -= 1; _show_page())
	get_node(^"Pager/Next").pressed.connect(func(): _page += 1; _show_page())
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
		row.get_node(^"Inset/Row/Icon").self_modulate = Color("44e9e9") if str(entry.id) == selected_id else Color("91999a")
		var pending := bool(entry.get("pending", false))
		row.get_node(^"Inset/Row/Value").add_theme_font_size_override("font_size", 12 if pending else 20)
		row.get_node(^"Inset/Row/Value").add_theme_color_override("font_color", Color("91999a") if pending else Color("44e9e9"))
		row.set_pressed_no_signal(str(entry.id) == selected_id)
		row.accessibility_name = "%s. %s. %s" % [entry.get("title", ""), entry.get("subtitle", ""), entry.get("value", "")]
	get_node(^"Caption/Title").text = caption
	get_node(^"Caption/Count").text = count
	_queue_fit()

func _queue_fit() -> void:
	if not is_node_ready() or _pending:
		return
	_pending = true
	_fit.call_deferred()

func _fit() -> void:
	var phone := get_viewport_rect().size.y <= 560
	var tablet := get_viewport_rect().size.x <= 1150 and not phone
	var height := 44 if phone else 56 if tablet else 68
	if tablet:
		var titles_only := true
		for entry in _entries:
			titles_only = titles_only and str(entry.get("subtitle", "")).is_empty()
		if titles_only:
			height = 48
	get_node(^"Area/Rows").columns = columns
	get_node(^"Area/Rows").add_theme_constant_override("v_separation", 2 if phone else 4)
	get_node(^"Caption").custom_minimum_size.y = 28 if phone else 42
	get_node(^"Pager").custom_minimum_size.y = 48 if phone else 53
	for label in [^"Caption/Title", ^"Caption/Count", ^"Pager/Range"]:
		get_node(label).add_theme_font_size_override("font_size", 10 if phone else 12)
	for button in [^"Pager/Previous", ^"Pager/Next"]:
		get_node(button).add_theme_font_size_override("font_size", 12 if phone else 15)
	for row in _rows:
		row.custom_minimum_size.y = height
		row.get_node(^"Inset/Row/Copy/Title").add_theme_font_size_override("font_size", 14 if phone and columns == 2 else 15 if phone else 16 if tablet else 20)
		row.get_node(^"Inset/Row/Copy/Subtitle").add_theme_font_size_override("font_size", 10 if phone else 11 if tablet else 12)
		row.get_node(^"Inset/Row/Icon").custom_minimum_size = Vector2(23, 23) if phone else Vector2(26, 26) if tablet else Vector2(30, 30)
		row.get_node(^"Inset/Row").add_theme_constant_override("separation", 8 if phone else 10 if tablet else 14)
		for edge in ["left", "right", "top", "bottom"]:
			row.get_node(^"Inset").add_theme_constant_override("margin_" + edge, (9 if edge in ["left", "right"] else 4) if phone else (10 if edge in ["left", "right"] else 8) if tablet else (16 if edge in ["left", "right"] else 9))
		row.get_node(^"Inset/Row/Value").size_flags_horizontal = Control.SIZE_FILL if columns > 1 or tablet else Control.SIZE_EXPAND_FILL
		var value := row.get_node(^"Inset/Row/Value") as Label
		var pending := bool(_entries[_rows.find(row)].get("pending", false))
		value.add_theme_font_size_override("font_size", 12 if pending else 17 if tablet else 20)
		var measured := value.get_theme_font("font").get_string_size(value.text, HORIZONTAL_ALIGNMENT_LEFT, -1, value.get_theme_font_size("font_size")).x
		value.custom_minimum_size.x = minf(ceilf(measured), size.x * 0.3) if tablet else 14 if columns > 1 else 0

	# The authored row has an inset Control, so include its effective child
	# minimum as well as the framed Button's minimum (ADR-0017).
	for row in _rows:
		height = maxi(height, ceili(maxf(row.get_combined_minimum_size().y, row.get_node(^"Inset").get_combined_minimum_size().y)))
		row.custom_minimum_size.y = height
	var available: float = size.y - get_node(^"Caption").get_combined_minimum_size().y
	var gap := 2 if phone else 4
	_capacity = maxi(columns, floori((available + gap) / (height + gap)) * columns)
	if _capacity < _rows.size():
		_capacity = maxi(columns, floori((available - get_node(^"Pager").get_combined_minimum_size().y + gap) / (height + gap)) * columns)
	get_node(^"Pager").visible = _capacity < _rows.size()
	if _reveal:
		for index in _entries.size():
			if str(_entries[index].id) == _selected:
				_page = index / _capacity
	_reveal = false
	_show_page()
	_pending = false
	queue_redraw()

func _draw() -> void:
	draw_line(Vector2(0, 0.5), Vector2(size.x, 0.5), Color("465256"))
	var pager := get_node_or_null(^"Pager") as Control
	if pager != null and pager.visible:
		draw_line(Vector2(0, pager.position.y), Vector2(size.x, pager.position.y), Color("465256"))

func _show_page() -> void:
	var pages := maxi(1, ceili(float(_rows.size()) / _capacity))
	_page = clampi(_page, 0, pages - 1)
	for index in _rows.size():
		_rows[index].visible = index >= _page * _capacity and index < (_page + 1) * _capacity
	get_node(^"Pager/Previous").disabled = _page == 0
	get_node(^"Pager/Next").disabled = _page == pages - 1
	get_node(^"Pager/Range").text = "%d–%d of %d" % [_page * _capacity + 1, mini((_page + 1) * _capacity, _rows.size()), _rows.size()]
