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
	resized.connect(_arrange)
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
		row.get_node(^"Copy/Title").text = str(entry.get("title", ""))
		row.get_node(^"Copy/Package").text = str(entry.get("package", ""))
		row.disabled = not bool(entry.get("available", true))
		row.accessibility_name = "%s · %s" % [str(entry.get("title", "")), str(entry.get("package", ""))]
		if row.disabled:
			row.get_node(^"Copy/Package").text += " · " + _text("unavailable", "Unavailable")
		row.pressed.connect(_select.bind(str(entry.id)))
		get_node(^"Results/Rows").add_child(row)
		_rows.append(row)
	set_state("ready")
	_select(_selection, false)

func selection() -> Dictionary:
	for entry in _entries:
		if str(entry.id) == _selection and bool(entry.get("available", true)):
			return entry.duplicate(true)
	return {}

func set_state(state: String, message: String = "") -> void:
	_state = state
	get_node(^"Search").editable = state == "ready"
	get_node(^"Results").visible = state == "ready" and not _entries.is_empty()
	get_node(^"PreviewRow").visible = state == "ready" and not selection().is_empty()
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
		_rows[index].get_node(^"Copy/Title").text = ("✓ " if chosen else "") + str(_entries[index].title)
	var entry := selection()
	get_node(^"PreviewRow").visible = not entry.is_empty() and _state == "ready"
	if not entry.is_empty():
		get_node(^"PreviewRow/Name").text = str(entry.title)
		preview_requested.emit(entry, get_node(^"PreviewRow/Preview"))
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
	get_node(^"PreviewRow/Preview").custom_minimum_size = Vector2(64, 64) if size.y < 420 else Vector2(144, 160)

func _text(key: String, fallback: String) -> String:
	return str(_labels.get(key, fallback))

func focus_search() -> void:
	get_node(^"Search").grab_focus()
