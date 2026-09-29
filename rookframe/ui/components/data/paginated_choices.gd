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
	for row in _rows:
		row.custom_minimum_size.y = height
		row.get_node(^"Inset/Row/Copy/Title").add_theme_font_size_override("font_size", 15 if phone else 16 if tablet else 20)
		row.get_node(^"Inset/Row/Copy/Subtitle").add_theme_font_size_override("font_size", 10 if phone else 11 if tablet else 12)
	var available: float = size.y - get_node(^"Caption").size.y
	_capacity = maxi(1, floori((available + 4) / (height + 4)))
	if _capacity < _rows.size():
		_capacity = maxi(1, floori((available - 53 + 4) / (height + 4)))
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
	draw_line(Vector2.ZERO, Vector2(size.x, 0), Color("465256"))
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
