@tool
extends VBoxContainer
const Records = preload("res://rookframe/ui/_internal/interaction/records.gd")
const Focus = preload("res://rookframe/ui/_internal/interaction/focus.gd")
@export var focus_fallback: Control
## Data-driven Miniature selection. The caller owns content, localization,
## preview rendering and persistence. Entries: id, title, package, available.
signal selection_changed(entry: Dictionary)
signal preview_requested(entry: Dictionary, target: Control)
signal retry_requested
@export var paginated := false
@export var reduced_motion := false
var _arrange_pending := false
var _page := 0
var _capacity := 1
var _matches: Array[int] = []
var _ink := preload("res://rookframe/ui/_internal/surfaces/content_reveal.gd").new()
@export var reveal_shader: Shader:
	set(value):
		reveal_shader = value
		_ink.shader = value
const ROW = preload("res://rookframe/ui/_internal/content/miniature_browser_row.tscn")
@export var row_scene: PackedScene = ROW
var _entries: Array[Dictionary] = []
var _selection := ""
var _rows: Array[Button] = []
var _labels: Dictionary = {}
var _state := "ready"

func _ready() -> void:
	theme_changed.connect(_queue_arrange)
	get_node(^"Search").text_changed.connect(_filter)
	get_node(^"Retry").pressed.connect(func(): retry_requested.emit())
	get_node(^"Results").resized.connect(_arrange)
	get_node(^"Pager/Previous").pressed.connect(_turn.bind(-1))
	get_node(^"Pager/Next").pressed.connect(_turn.bind(1))
	_arrange()

## Supply localized copy; no locale is selected globally by this component.
func configure(entries: Array[Dictionary], selected_id: String = "", labels: Dictionary = {}) -> void:
	if not Records.valid(entries): return
	var focused := get_viewport().gui_get_focus_owner()
	var former := Records.focused_index(_rows, focused)
	var retained := Records.reconcile(entries, _entries, _rows, get_node(^"Results/Rows"), _create_row)
	_rows.assign(retained)
	_entries = entries.duplicate(true)
	_selection = selected_id
	_labels = labels.duplicate(true)
	get_node(^"Search").placeholder_text = _text("search", "Search Miniatures")
	get_node(^"Search").accessibility_name = _text("search", "Search Miniatures")
	get_node(^"Retry").text = _text("retry", "Try again")
	get_node(^"Pager/Previous").text = _text("previous", "Previous")
	get_node(^"Pager/Next").text = _text("next", "Next")
	for index in _entries.size():
		var entry := _entries[index]
		var row := _rows[index]
		row.get_node(^"Content/Copy/Title").text = str(entry.get("title", ""))
		row.get_node(^"Content/Copy/Package").text = str(entry.get("package", ""))
		row.disabled = not bool(entry.get("available", true))
		row.focus_mode = Control.FOCUS_NONE if row.disabled else Control.FOCUS_ALL
		row.get_node(^"Content/Copy/Package").visible = not str(entry.get("package", "")).is_empty()
		row.accessibility_name = str(entry.get("title", "")) + (" · " + str(entry.package) if not str(entry.get("package", "")).is_empty() else "")
		row.get_node(^"Content/Stage/Fallback").text = _text("unavailable", "Unavailable") if row.disabled else _text("preview_unavailable", "Preview unavailable")
		if not row.disabled: preview_requested.emit(entry.duplicate(true), row.get_node(^"Content/Stage/Preview"))
	_state = "ready"
	get_node(^"Search").editable = true
	get_node(^"Results").visible = not _entries.is_empty()
	get_node(^"Retry").visible = false
	_select(_selection, false)
	_filter(get_node(^"Search").text, false)
	if former >= 0:
		if is_instance_valid(focused) and _rows.has(focused): focus_entry(_entries[_rows.find(focused)].id)
		else: Focus.restore(_rows, former, focus_fallback)

func _create_row(id: String) -> Control:
	var row := row_scene.instantiate() as Button
	row.pressed.connect(_select.bind(id))
	row.get_node(^"Content/Copy").minimum_size_changed.connect(_queue_arrange)
	return row

func selection() -> Dictionary:
	for entry in _entries:
		if str(entry.id) == _selection and bool(entry.get("available", true)):
			return entry.duplicate(true)
	return {}

func set_state(state: String, message: String = "") -> void:
	_state = state
	get_node(^"Search").editable = state == "ready"
	get_node(^"Results").visible = state == "ready" and not _entries.is_empty()
	get_node(^"Retry").visible = state == "error"
	get_node(^"Status").visible = true
	get_node(^"Status").text = message if not message.is_empty() else (_text("loading", "Loading Miniatures…") if state == "loading" else "")
	if state == "ready":
		_filter(get_node(^"Search").text)

func _select(id: String, notify := true) -> void:
	_selection = id
	for index in range(_rows.size()):
		var chosen := str(_entries[index].id) == id
		_rows[index].set_pressed_no_signal(chosen)
		var row: Button = _rows[index]
		_style_row(row)
		_rows[index].get_node(^"Content/Copy/Title").text = str(_entries[index].title)
		_rows[index].get_node(^"Selected").visible = chosen
		_rows[index].accessibility_description = _text("selected", "Selected") if chosen else ""
	var entry := selection()
	if notify:
		selection_changed.emit(entry)

func _filter(query: String, reset_page := true) -> void:
	_matches.clear()
	if reset_page: _page = 0
	var count := 0
	for index in range(_rows.size()):
		var entry := _entries[index]
		var matches := query.strip_edges().is_empty() or (str(entry.title) + " " + str(entry.get("package", ""))).to_lower().contains(query.strip_edges().to_lower())
		_rows[index].visible = matches
		if matches:
			_matches.append(index)
			count += 1
	get_node(^"Status").text = _text("empty", "Add a Miniature Package to this World.") if _entries.is_empty() else (_text("no_match", "No matching Miniatures.") if count == 0 else "")
	get_node(^"Status").visible = not get_node(^"Status").text.is_empty()
	_arrange()

func _queue_arrange() -> void:
	if _arrange_pending: return
	_arrange_pending = true
	get_tree().process_frame.connect(_run_arrange, CONNECT_ONE_SHOT)

func _run_arrange() -> void:
	_arrange_pending = false
	_arrange()

func _arrange() -> void:
	if not is_inside_tree():
		return
	var results := get_node(^"Results") as ScrollContainer
	results.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER if paginated else ScrollContainer.SCROLL_MODE_AUTO
	get_node(^"Pager").visible = paginated and _state == "ready" and not _matches.is_empty()
	var width: float = results.size.x - (0 if paginated else results.get_v_scroll_bar().get_combined_minimum_size().x)
	var columns := clampi(int((width + 12) / 148), 1, 4)
	if paginated: columns = clampi(int((width + 12) / 148), 1, 4)
	get_node(^"Results/Rows").columns = columns
	var caption_height := 44.0
	for row in _rows:
		caption_height = maxf(caption_height, row.get_node(^"Content/Copy").get_combined_minimum_size().y)
	var preview_height := clampf(minf((width - (columns - 1) * 12) / columns - 16,
		results.size.y - caption_height - 24), 96, 220)
	if paginated:
		var rows := maxi(1, floori((results.size.y + 12) / (caption_height + 24 + 48 + 12)))
		_capacity = columns * rows
		preview_height = maxf(24, floorf((results.size.y - (rows - 1) * 12) / rows) - caption_height - 24)
	for row in _rows:
		row.minimum_height = 0 if paginated else 148
		row.custom_minimum_size.y = preview_height + caption_height + 24 if paginated else 148
		row.get_node(^"Content/Stage").custom_minimum_size.y = preview_height
	if paginated:
		var focused := _rows.find(get_viewport().gui_get_focus_owner())
		if focused in _matches: _page = _matches.find(focused) / _capacity
		_show_page()

func _turn(delta: int) -> void:
	_page += delta
	_show_page()
	_queue_arrange()
	_ink.play(get_node(^"Results/Rows"), reduced_motion)

func _show_page() -> void:
	get_node(^"Results").scroll_vertical = 0
	_page = clampi(_page, 0, maxi(0, ceili(float(_matches.size()) / _capacity) - 1))
	var first := _page * _capacity
	var last := mini(first + _capacity, _matches.size())
	# Keep visible cards in the tree's input path while layout settles. Hiding
	# and re-showing a held Button cancels its native mouse press.
	var visible_indices := _matches.slice(first, last)
	for index in _rows.size(): _rows[index].visible = index in visible_indices
	get_node(^"Pager/Range").text = "%d–%d / %d" % [first + 1, last, _matches.size()] if not _matches.is_empty() else tr("0 entries")
	get_node(^"Pager/Previous").disabled = _page == 0
	get_node(^"Pager/Next").disabled = last == _matches.size()

func _exit_tree() -> void:
	_ink.finish()

func _text(key: String, fallback: String) -> String:
	return str(_labels.get(key, fallback))

func focus_search() -> void:
	get_node(^"Search").grab_focus()

func _style_row(row: Button) -> void:
	pass

func focus_entry(id: String) -> bool:
	if not is_visible_in_tree(): return false
	for index in _entries.size():
		if _entries[index].id == id and index in _matches and not _rows[index].disabled:
			if paginated:
				_page = _matches.find(index) / _capacity
				_show_page()
			return Focus.give(_rows[index])
	return false

func capture_state() -> Dictionary:
	return {"page": _page, "query": get_node(^"Search").text}

func restore_state(state: Dictionary) -> void:
	get_node(^"Search").text = str(state.get("query", ""))
	_filter(get_node(^"Search").text)
	_page = maxi(0, int(state.get("page", 0)))
	_arrange()
