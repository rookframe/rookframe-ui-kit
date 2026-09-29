@tool
extends Control
## Approved full-viewport Miniature browser. The consumer owns previews and persistence.
signal selection_changed(entry: Dictionary)
signal preview_requested(entry: Dictionary, target: Control)
signal retry_requested
signal choose_requested(entry: Dictionary)
signal cancel_requested
signal close_requested

const CARD = preload("res://rookframe/ui/_internal/content/fullscreen_miniature_card.tscn")
var _entries: Array[Dictionary] = []
var _cards: Array[Button] = []
var _selection := ""
var _labels: Dictionary = {}
var _state := "ready"
var _message := ""
var _page := 0
var _pages: Array[Array] = []
var _arrange_pending := false
var _revision := 0
var _reveal_selection := false
@onready var _search: LineEdit = get_node(^"Layout/SearchArea/Content/Search")
@onready var _grid: GridContainer = get_node(^"Layout/Results/Content/GridArea/Rows")
@onready var _area: Control = get_node(^"Layout/Results/Content/GridArea")
@onready var _pager: HBoxContainer = get_node(^"Layout/Results/Content/Pager")

func _ready() -> void:
	_search.text_changed.connect(func(_query): _revision += 1; _page = 0; _queue_arrange())
	get_node(^"Layout/Header/Row/Close").pressed.connect(func(): close_requested.emit())
	get_node(^"Layout/Footer/Row/Cancel").pressed.connect(func(): cancel_requested.emit())
	get_node(^"Layout/Footer/Row/Choose").pressed.connect(_choose)
	get_node(^"Layout/Results/Content/State/Retry").pressed.connect(func(): retry_requested.emit())
	_pager.get_node(^"Previous").pressed.connect(func(): _page -= 1; _show_page())
	_pager.get_node(^"Next").pressed.connect(func(): _page += 1; _show_page())
	resized.connect(_queue_arrange)
	_area.resized.connect(_queue_arrange)
	_queue_arrange()

func configure(entries: Array[Dictionary], selected_id: String = "", labels: Dictionary = {}) -> void:
	_revision += 1
	_entries = entries.duplicate(true)
	_selection = selected_id
	_labels = labels
	_page = 0
	_reveal_selection = true
	_search.text = ""
	for card in _cards:
		_grid.remove_child(card)
		card.queue_free()
	_cards.clear()
	for entry in _entries:
		var card := CARD.instantiate() as Button
		card.get_node(^"Content/Copy/Title").text = str(entry.get("title", ""))
		card.get_node(^"Content/Copy/Package").text = str(entry.get("package", ""))
		card.disabled = not bool(entry.get("available", true))
		card.accessibility_name = str(entry.get("title", "")) + " · " + str(entry.get("package", ""))
		card.get_node(^"Content/Stage/Fallback").text = _text("unavailable", "Miniature unavailable") if card.disabled else _text("preview_unavailable", "Preview unavailable")
		card.pressed.connect(_select.bind(str(entry.id)))
		_grid.add_child(card)
		_cards.append(card)
		if not card.disabled:
			preview_requested.emit(entry.duplicate(true), card.get_node(^"Content/Stage/Preview"))
	_localize()
	set_state("ready")
	_select(_selection, false)

func selection() -> Dictionary:
	for entry in _entries:
		if str(entry.id) == _selection and bool(entry.get("available", true)):
			return entry.duplicate(true)
	return {}

func set_state(state: String, message: String = "") -> void:
	_revision += 1
	_state = state
	_message = message
	_search.editable = state == "ready"
	_select(_selection, false)
	_queue_arrange()

func focus_search() -> void:
	_search.grab_focus()

func _choose() -> void:
	if _state == "ready" and not selection().is_empty():
		choose_requested.emit(selection())

func _select(id: String, notify := true) -> void:
	_selection = id
	var chosen: Dictionary = {}
	for index in range(_cards.size()):
		var selected := str(_entries[index].id) == id
		_cards[index].set_pressed_no_signal(selected)
		_cards[index].get_node(^"Selected").visible = selected
		_cards[index].accessibility_description = _text("selected", "Selected") if selected else ""
		if selected:
			chosen = _entries[index]
	get_node(^"Layout/Footer/Row/Selection/Name").text = str(chosen.get("title", _text("none", "None")))
	get_node(^"Layout/Footer/Row/Selection/Package").text = str(chosen.get("package", ""))
	_fit_selection()
	get_node(^"Layout/Footer/Row/Choose").disabled = _state != "ready" or selection().is_empty()
	get_node(^"Layout/SearchArea/Content/Meta/Hint").text = _text("saved_unavailable", "Saved miniature unavailable. Choose a replacement, or cancel to keep it.") if not chosen.is_empty() and not bool(chosen.get("available", true)) else _text("hint", "Choose an appearance for your character’s Rooks.")
	if notify:
		selection_changed.emit(selection())

func _queue_arrange() -> void:
	if not is_node_ready() or _arrange_pending:
		return
	_arrange_pending = true
	_arrange.call_deferred()

func _fit_selection() -> void:
	var label := get_node(^"Layout/Footer/Row/Selection/Name") as Label
	label.custom_minimum_size.x = minf(label.get_theme_font("font").get_string_size(label.text, HORIZONTAL_ALIGNMENT_LEFT, -1, label.get_theme_font_size("font_size")).x, size.x / 4)

func _arrange() -> void:
	var revision := _revision
	var phone := size.y <= 560
	var tablet := not phone and size.x <= 1150
	var inset := 16 if phone else (24 if tablet else 40)
	get_node(^"Layout/Header").custom_minimum_size.y = 48 if phone else (96 if tablet else 116)
	get_node(^"HeaderBackground").offset_bottom = 48 if phone else (96 if tablet else 116)
	get_node(^"Layout/Header/Row/Copy/Kicker").visible = not phone
	get_node(^"Layout/Header/Row/Copy/Title").add_theme_font_size_override("font_size", 23 if phone else 30)
	get_node(^"Layout/Header/Row/Close").custom_minimum_size = Vector2(44, 44) if phone else Vector2(48, 48)
	get_node(^"Layout/Footer").custom_minimum_size.y = 54 if phone else (66 if tablet else 80)
	get_node(^"FooterBackground").offset_top = -54 if phone else (-66 if tablet else -80)
	get_node(^"Layout/Footer/Row/Selection/Label").visible = not phone
	get_node(^"Layout/Footer/Row/Choose").custom_minimum_size.x = 156 if phone else 204
	get_node(^"Layout/Footer/Row/Cancel").custom_minimum_size.x = 84 if phone else 120
	get_node(^"Layout/Footer/Row").add_theme_constant_override("separation", 12 if phone else 24)
	get_node(^"Layout/Footer/Row/Selection/Name").add_theme_font_size_override("font_size", 15 if phone else 18)
	get_node(^"Layout/Footer/Row/Selection/Package").add_theme_font_size_override("font_size", 10 if phone else 12)
	_fit_selection()
	get_node(^"Layout/SearchArea/Content/Meta/Hint").add_theme_font_size_override("font_size", 11 if phone else 13)
	get_node(^"Layout/SearchArea/Content/Meta/Count").add_theme_font_size_override("font_size", 10 if phone else 12)
	_search.add_theme_font_size_override("font_size", 14 if phone else 16)
	for button in [get_node(^"Layout/Footer/Row/Choose"), get_node(^"Layout/Footer/Row/Cancel"), _pager.get_node(^"Next"), _pager.get_node(^"Previous")]:
		button.add_theme_font_size_override("font_size", 12 if phone else 15)
	get_node(^"Layout/SearchArea").add_theme_constant_override("margin_top", 8 if phone else (20 if tablet else 28))
	get_node(^"Layout/SearchArea/Content/Meta").custom_minimum_size.y = 24 if phone else 52
	_search.custom_minimum_size.y = 44 if phone else 50
	for node in [get_node(^"Layout/Header"), get_node(^"Layout/SearchArea"), get_node(^"Layout/Results"), get_node(^"Layout/Footer")]:
		node.add_theme_constant_override("margin_left", inset)
		node.add_theme_constant_override("margin_right", inset)
	get_node(^"Layout/Results").add_theme_constant_override("margin_bottom", 8 if phone else (24 if tablet else 28))
	_grid.columns = 3 if phone or tablet else 4
	var gap := 12 if phone or tablet else 16
	_grid.add_theme_constant_override("h_separation", gap)
	_grid.add_theme_constant_override("v_separation", gap)
	var matches: Array[int] = []
	var query := _search.text.strip_edges().to_lower()
	for index in range(_entries.size()):
		var entry := _entries[index]
		var match := _state == "ready" and (query.is_empty() or (str(entry.title) + " " + str(entry.get("package", ""))).to_lower().contains(query))
		_cards[index].visible = match
		if match:
			matches.append(index)
	_area.visible = not matches.is_empty()
	_pager.visible = matches.size() > _grid.columns
	_update_state(matches.size())
	await get_tree().process_frame
	if revision != _revision:
		_arrange_pending = false
		_queue_arrange()
		return
	var width := (_area.size.x - gap * (_grid.columns - 1)) / _grid.columns
	for card in _cards:
		card.arrange(width, phone, tablet)
	await get_tree().process_frame
	await get_tree().process_frame
	if revision != _revision:
		_arrange_pending = false
		_queue_arrange()
		return
	_pages.clear()
	var current: Array = []
	var height := 0.0
	for offset in range(0, matches.size(), _grid.columns):
		var row := matches.slice(offset, offset + _grid.columns)
		var row_height := 0.0
		for index in row:
			row_height = maxf(row_height, _cards[index].get_combined_minimum_size().y)
		if not current.is_empty() and height + gap + row_height > _area.size.y + 1:
			_pages.append(current)
			current = []
			height = 0
		height += (0 if current.is_empty() else gap) + row_height
		current.append_array(row)
	if not current.is_empty():
		_pages.append(current)
	if _reveal_selection:
		for index in range(_pages.size()):
			if _pages[index].any(func(card): return str(_entries[card].id) == _selection):
				_page = index
		_reveal_selection = false
	_pager.visible = _pages.size() > 1
	_show_page()
	_arrange_pending = false

func _show_page() -> void:
	_page = clampi(_page, 0, maxi(0, _pages.size() - 1))
	var current: Array = [] if _pages.is_empty() else _pages[_page]
	for index in range(_cards.size()):
		_cards[index].visible = current.has(index)
	_pager.get_node(^"Previous").disabled = _page == 0
	_pager.get_node(^"Next").disabled = _page >= _pages.size() - 1
	var total := 0
	var offset := 0
	for index in range(_pages.size()):
		if index < _page:
			offset += _pages[index].size()
		total += _pages[index].size()
	_pager.get_node(^"Range").text = _text("range", "%d–%d of %d") % [offset + 1, offset + current.size(), total] if total else ""

func _update_state(count: int) -> void:
	var state := get_node(^"Layout/Results/Content/State")
	state.visible = count == 0 or _state != "ready"
	state.get_node(^"Retry").visible = _state == "error"
	var title := _text("empty", "No miniatures in this World") if _entries.is_empty() else _text("no_match", "No matching miniatures")
	var message := _text("empty_copy", "Add a Miniature Package to this World to choose an appearance.") if _entries.is_empty() else _text("no_match_copy", "Try another name or Package.")
	if _state == "loading":
		title = _text("loading", "Loading miniatures…")
		message = _text("loading_copy", "Your selection will stay with you.")
	elif _state == "error":
		title = _text("error", "Could not load miniatures")
		message = _text("error_copy", "Try again, or cancel to return to your character.")
	state.get_node(^"Title").text = title
	state.get_node(^"Message").text = _message if not _message.is_empty() else message
	get_node(^"Layout/SearchArea/Content/Meta/Count").text = _text("count", "%d miniatures") % count

func _localize() -> void:
	_search.placeholder_text = _text("search", "Search by name or Package")
	_search.accessibility_name = _search.placeholder_text
	get_node(^"Layout/Header/Row/Copy/Kicker").text = _text("library", "WORLD CONTENT LIBRARY")
	get_node(^"Layout/Header/Row/Copy/Title").text = _text("title", "Choose a miniature")
	get_node(^"Layout/Header/Row/Close").accessibility_name = _text("close", "Close miniature browser")
	get_node(^"Layout/Footer/Row/Cancel").text = _text("cancel", "Cancel")
	get_node(^"Layout/Footer/Row/Choose").text = _text("choose", "Choose")
	get_node(^"Layout/Footer/Row/Selection/Label").text = _text("selection", "Selected miniature")
	get_node(^"Layout/SearchArea/Content/Meta/Hint").text = _text("hint", "Choose an appearance for your character’s Rooks.")
	_pager.get_node(^"Previous").text = _text("previous", "Previous")
	_pager.get_node(^"Next").text = _text("next", "Next")
	get_node(^"Layout/Results/Content/State/Retry").text = _text("retry", "Try again")

func _text(key: String, fallback: String) -> String:
	return str(_labels.get(key, fallback))
