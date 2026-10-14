@tool
extends VBoxContainer
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
const ROW = preload("res://rookframe/ui/_internal/content/miniature_browser_row.tscn")
var _entries: Array[Dictionary] = []
var _selection := ""
var _rows: Array[Button] = []
var _labels: Dictionary = {}
var _state := "ready"

func _ready() -> void:
	get_node(^"Search").text_changed.connect(_filter)
	get_node(^"Retry").pressed.connect(func(): retry_requested.emit())
	get_node(^"Results").resized.connect(_arrange)
	get_node(^"Pager/Previous").pressed.connect(_turn.bind(-1))
	get_node(^"Pager/Next").pressed.connect(_turn.bind(1))
	_arrange()

## Supply localized copy; no locale is selected globally by this component.
func configure(entries: Array[Dictionary], selected_id: String = "", labels: Dictionary = {}) -> void:
	_entries = entries.duplicate(true)
	_page = 0
	_selection = selected_id
	_labels = labels
	get_node(^"Search").placeholder_text = _text("search", "Search Miniatures")
	get_node(^"Search").accessibility_name = _text("search", "Search Miniatures")
	get_node(^"Retry").text = _text("retry", "Try again")
	get_node(^"Pager/Previous").text = _text("previous", "Previous")
	get_node(^"Pager/Next").text = _text("next", "Next")
	for row in _rows:
		row.get_parent().remove_child(row)
		row.queue_free()
	_rows.clear()
	for entry in _entries:
		var row := ROW.instantiate() as Button
		row.get_node(^"Content/Copy/Title").text = str(entry.get("title", ""))
		row.get_node(^"Content/Copy/Package").text = str(entry.get("package", ""))
		row.disabled = not bool(entry.get("available", true))
		row.get_node(^"Content/Copy/Package").visible = not str(entry.get("package", "")).is_empty()
		row.accessibility_name = str(entry.get("title", ""))
		if not str(entry.get("package", "")).is_empty():
			row.accessibility_name += " · " + str(entry.package)
		if row.disabled:
			row.get_node(^"Content/Stage/Fallback").text = _text("unavailable", "Unavailable")
		else:
			row.get_node(^"Content/Stage/Fallback").text = _text("preview_unavailable", "Preview unavailable")
		row.pressed.connect(_select.bind(str(entry.id)))
		get_node(^"Results/Rows").add_child(row)
		row.get_node(^"Content/Copy").minimum_size_changed.connect(_queue_arrange)
		_rows.append(row)
		if not row.disabled:
			preview_requested.emit(entry.duplicate(true), row.get_node(^"Content/Stage/Preview"))
	set_state("ready")
	_select(_selection, false)
	_arrange()

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
		for state in ["normal", "hover", "pressed", "hover_pressed", "disabled"]:
			var box := StyleBoxFlat.new()
			box.bg_color = Color("bc927726") if state in ["pressed", "hover_pressed"] else Color("080b0a66")
			box.set_border_width_all(1)
			box.border_color = Color("bc9277") if state in ["pressed", "hover_pressed"] else Color("bc927747")
			row.add_theme_stylebox_override(state, box)
		row.get_node(^"Selected").add_theme_color_override("font_color", Color("151719"))
		var selected_box := StyleBoxFlat.new()
		selected_box.bg_color = Color("ceccb3")
		row.get_node(^"Selected").add_theme_stylebox_override("normal", selected_box)
		_rows[index].get_node(^"Content/Copy/Title").text = str(_entries[index].title)
		_rows[index].get_node(^"Selected").visible = chosen
		_rows[index].accessibility_description = _text("selected", "Selected") if chosen else ""
	var entry := selection()
	if notify:
		selection_changed.emit(entry)

func _filter(query: String) -> void:
	_matches.clear()
	_page = 0
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
	if paginated: columns = 3 if get_viewport_rect().size.y <= 560 else 4
	get_node(^"Results/Rows").columns = columns
	var caption_height := 44.0
	for row in _rows:
		caption_height = maxf(caption_height, row.get_node(^"Content/Copy").get_combined_minimum_size().y)
	var preview_height := clampf(minf((width - (columns - 1) * 12) / columns - 16,
		results.size.y - caption_height - 24), 96, 220)
	if paginated:
		var rows := 1 if get_viewport_rect().size.y <= 560 else 2
		_capacity = columns * rows
		preview_height = maxf(24, floorf((results.size.y - (rows - 1) * 12) / rows) - caption_height - 24)
	for row in _rows:
		row.minimum_height = 0 if paginated else 148
		row.custom_minimum_size.y = preview_height + caption_height + 24 if paginated else 148
		row.get_node(^"Content/Stage").custom_minimum_size.y = preview_height
	if paginated: _show_page()

func _turn(delta: int) -> void:
	_page += delta
	_show_page()
	_queue_arrange()
	_ink.play(get_node(^"Results/Rows"), reduced_motion)

func _show_page() -> void:
	get_node(^"Results").scroll_vertical = 0
	_page = clampi(_page, 0, maxi(0, ceili(float(_matches.size()) / _capacity) - 1))
	for row in _rows: row.hide()
	var first := _page * _capacity
	var last := mini(first + _capacity, _matches.size())
	for index in range(first, last): _rows[_matches[index]].show()
	get_node(^"Pager/Range").text = "%d–%d / %d" % [first + 1, last, _matches.size()]
	get_node(^"Pager/Previous").disabled = _page == 0
	get_node(^"Pager/Next").disabled = last == _matches.size()

func _exit_tree() -> void:
	_ink.finish()

func _text(key: String, fallback: String) -> String:
	return str(_labels.get(key, fallback))

func focus_search() -> void:
	get_node(^"Search").grab_focus()
