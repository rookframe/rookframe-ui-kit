@tool
extends Control
## Full-screen miniature choice; callers own acquisition, previews and saves.
signal selection_changed(entry: Dictionary)
signal preview_requested(entry: Dictionary, target: Control)
signal retry_requested
signal choose_requested(entry: Dictionary)
signal cancel_requested
signal close_requested
const HEADER := "Inset/Layout/Header/Row/"
const BODY := "Inset/Layout/Body/"
const FOOTER := "Inset/Layout/Footer/"
var _labels: Dictionary = {}
var _state := "ready"
@onready var browser = get_node(BODY + "Browser")

func _ready() -> void:
	browser.selection_changed.connect(_selected)
	browser.preview_requested.connect(func(entry, target): preview_requested.emit(entry, target))
	browser.retry_requested.connect(func(): retry_requested.emit())
	get_node(HEADER + "Close").pressed.connect(func(): close_requested.emit())
	get_node(FOOTER + "Cancel").pressed.connect(func(): cancel_requested.emit())
	get_node(FOOTER + "Choose").pressed.connect(func():
		if _state == "ready" and not selection().is_empty(): choose_requested.emit(selection()))
	resized.connect(_arrange)
	get_node("Inset/Layout/Body").item_rect_changed.connect(_fit_frame)
	get_node("Inset/Layout/Footer").item_rect_changed.connect(_fit_frame)
	_arrange()

func configure(entries: Array[Dictionary], selected_id: String = "", labels: Dictionary = {}) -> void:
	_labels = labels.duplicate(true)
	get_node(HEADER + "Copy/Title").text = _text("title", "Choose a miniature")
	get_node(HEADER + "Copy/Kicker").hide()
	get_node(BODY + "Note").text = _text("hint", "")
	get_node(BODY + "Note").visible = not _text("hint", "").is_empty()
	get_node(FOOTER + "Cancel").text = _text("cancel", "Cancel")
	get_node(FOOTER + "Choose").text = _text("choose", "Choose")
	get_node(HEADER + "Close").accessibility_name = _text("close", "Close miniature browser")
	get_node(HEADER + "Close").tooltip_text = _text("close", "Close miniature browser")
	browser.configure(entries, selected_id, labels)
	_state = "ready"
	_selected(selection())
	_arrange()

func selection() -> Dictionary:
	return browser.selection()

func focus_search() -> void:
	browser.focus_search()

func set_state(state: String, message: String = "") -> void:
	_state = state
	browser.set_state(state, message)
	get_node(FOOTER + "Choose").disabled = state != "ready" or selection().is_empty()

func _selected(entry: Dictionary) -> void:
	get_node(FOOTER + "Selection").text = str(entry.get("title", _text("none", "None")))
	get_node(FOOTER + "Choose").disabled = _state != "ready" or entry.is_empty()
	selection_changed.emit(entry)

func _arrange() -> void:
	if not is_node_ready(): return
	var phone := size.y <= 560
	var outer := 12 if phone else 16 if size.x <= 1300 else 28
	for edge in ["left", "right"]: get_node("Inset").add_theme_constant_override("margin_" + edge, outer + 16)
	for edge in ["top", "bottom"]: get_node("Inset").add_theme_constant_override("margin_" + edge, outer + 8)
	get_node("Inset/Layout").add_theme_constant_override("separation", 20 if phone else 24)
	get_node("Inset/Layout/Header").custom_minimum_size.y = 44 if phone else 56
	get_node(HEADER + "Copy/Title").add_theme_font_size_override("font_size", 25 if phone else 32)
	get_node(BODY + "Note").add_theme_font_size_override("font_size", 13 if phone else 18)
	get_node("Inset/Layout/Footer").custom_minimum_size.y = 48 if phone else 60
	for path in [HEADER + "Close", FOOTER + "Cancel", FOOTER + "Choose"]:
		var action: Button = get_node(path)
		action.custom_minimum_size.y = 44
		action.add_theme_font_size_override("font_size", 18 if phone else 20)
		for state in ["normal", "hover", "pressed", "disabled"]:
			var box := action.get_theme_stylebox(state).duplicate()
			box.content_margin_top = 4
			box.content_margin_bottom = 4
			action.add_theme_stylebox_override(state, box)
	_fit_frame.call_deferred()

func _fit_frame() -> void:
	if not is_node_ready(): return
	var rects: Array[Rect2] = []
	for part in ["Header", "Body", "Footer"]:
		var item: Control = get_node("Inset/Layout/" + part)
		rects.append(Rect2(item.global_position - global_position - Vector2(16,8), item.size + Vector2(32,16)))
	get_node("Frame").set_sections(rects[0], rects[1], rects[2])

func _text(key: String, fallback: String) -> String:
	return str(_labels.get(key, fallback))
