@tool
extends VBoxContainer
## Data-driven Miniature selection. The caller owns content, localization,
## preview rendering and persistence. Entries: id, title, package, available.
signal selection_changed(entry: Dictionary)
signal preview_requested(entry: Dictionary, target: Control)
signal retry_requested
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
	_arrange()

## Supply localized copy; no locale is selected globally by this component.
func configure(entries: Array[Dictionary], selected_id: String = "", labels: Dictionary = {}) -> void:
	_entries = entries.duplicate(true)
	_selection = selected_id
	_labels = labels
	get_node(^"Search").placeholder_text = _text("search", "Search Miniatures")
	get_node(^"Search").accessibility_name = _text("search", "Search Miniatures")
	get_node(^"Retry").text = _text("retry", "Try again")
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
		_rows[index].get_node(^"Content/Copy/Title").text = str(_entries[index].title)
		_rows[index].get_node(^"Selected").visible = chosen
		_rows[index].accessibility_description = _text("selected", "Selected") if chosen else ""
	var entry := selection()
	if notify:
		selection_changed.emit(entry)

func _filter(query: String) -> void:
	var count := 0
	for index in range(_rows.size()):
		var entry := _entries[index]
		var matches := query.strip_edges().is_empty() or (str(entry.title) + " " + str(entry.get("package", ""))).to_lower().contains(query.strip_edges().to_lower())
		_rows[index].visible = matches
		if matches:
			count += 1
	get_node(^"Status").text = _text("empty", "Add a Miniature Package to this World.") if _entries.is_empty() else (_text("no_match", "No matching Miniatures.") if count == 0 else "")
	get_node(^"Status").visible = not get_node(^"Status").text.is_empty()

func _arrange() -> void:
	if not is_inside_tree():
		return
	var results := get_node(^"Results") as ScrollContainer
	var width := results.size.x - results.get_v_scroll_bar().get_combined_minimum_size().x
	var columns := clampi(int((width + 12) / 160), 1, 4)
	get_node(^"Results/Rows").columns = columns
	var caption_height := 44.0
	for row in _rows:
		caption_height = maxf(caption_height, row.get_node(^"Content/Copy").get_combined_minimum_size().y)
	var preview_height := clampf(minf((width - (columns - 1) * 12) / columns - 16,
		results.size.y - caption_height - 24), 96, 220)
	for row in _rows:
		row.get_node(^"Content/Stage").custom_minimum_size.y = preview_height

func _text(key: String, fallback: String) -> String:
	return str(_labels.get(key, fallback))

func focus_search() -> void:
	get_node(^"Search").grab_focus()
