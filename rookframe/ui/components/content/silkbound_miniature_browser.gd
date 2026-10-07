@tool
extends Control
## Silkbound list/preview composition. Consumers own acquisition, previews and saves.
signal selection_changed(entry: Dictionary)
signal preview_requested(entry: Dictionary, target: Control)
signal retry_requested
signal choose_requested(entry: Dictionary)
signal cancel_requested
signal close_requested
const ROW = preload("res://rookframe/ui/_internal/content/silkbound_miniature_row.tscn")
var _entries: Array[Dictionary] = []
var _rows: Array[Button] = []
var _labels: Dictionary = {}
var _selection := ""
var _state := "ready"
var _layout_frames := 0
@onready var _search: LineEdit = get_node("Inset/Layout/Body/Search/Editor")
@onready var _list: Control = get_node("Inset/Layout/Body/Columns/List")
@onready var _preview: Control = get_node("Inset/Layout/Body/Columns/Preview/Stage")
const HEADER := "Inset/Layout/Header/Row/"
const BODY := "Inset/Layout/Body/"
const FOOTER := "Inset/Layout/Footer/"

func _ready() -> void:
	_search.text_changed.connect(_filter)
	get_node(HEADER+"Close").pressed.connect(func(): close_requested.emit())
	get_node(FOOTER+"Cancel").pressed.connect(func(): cancel_requested.emit())
	get_node(FOOTER+"Choose").pressed.connect(func():
		if _state == "ready" and not selection().is_empty(): choose_requested.emit(selection()))
	get_node(BODY+"Retry").pressed.connect(func(): retry_requested.emit())
	resized.connect(_arrange)
	_arrange()

func configure(entries: Array[Dictionary], selected_id: String = "", labels: Dictionary = {}) -> void:
	_list.enabled = false
	_entries = entries.duplicate(true)
	_labels = labels.duplicate(true)
	_selection = selected_id
	_search.set_block_signals(true)
	_search.text = ""
	_search.set_block_signals(false)
	for row in _rows:
		row.get_parent().remove_child(row)
		row.queue_free()
	_rows.clear()
	for entry in _entries:
		var row: Button = ROW.instantiate()
		_list.get_node("Area/Rows").add_child(row)
		row.get_node("Inset/Row/Copy/Title").text = str(entry.get("title", ""))
		row.get_node("Inset/Row/Copy/Package").text = _text("none_copy", "No saved miniature") if str(entry.id) == "none" else str(entry.get("package", ""))
		row.get_node("Inset/Row/Thumbnail").visible = str(entry.id) != "none"
		row.disabled = not bool(entry.get("available", true))
		row.accessibility_name = str(entry.get("title", "")) + ". " + str(entry.get("package", ""))
		row.pressed.connect(_select.bind(str(entry.id)))
		row.get_node("Inset").minimum_size_changed.connect(_measure_rows, CONNECT_DEFERRED)
		_rows.append(row)
		if not row.disabled and str(entry.id) != "none":
			preview_requested.emit(entry.duplicate(true), row.get_node("Inset/Row/Thumbnail"))
	get_node(HEADER+"Copy/Kicker").text = _text("library", "")
	get_node(HEADER+"Copy/Title").text = _text("title", "Tabletop miniature")
	get_node(BODY+"Note").text = _text("hint", "")
	get_node(BODY+"Search/Label").text = _text("find", "Find miniature")
	_search.placeholder_text = _text("search", "Name or Package")
	_search.accessibility_name = _text("find", "Find miniature")
	for pair in [[HEADER+"Close","close","Close"],[FOOTER+"Cancel","cancel","Cancel"],[FOOTER+"Choose","choose","Use miniature"]]:
		get_node(pair[0]).accessibility_name = _text(pair[1],pair[2])
		get_node(pair[0]).tooltip_text = _text(pair[1],pair[2])
	for action in ["Previous", "Next"]:
		_list.get_node("Pager/"+action).accessibility_name = _text(action.to_lower(), action)
		_list.get_node("Pager/"+action).tooltip_text = _text(action.to_lower(), action)
	get_node(BODY+"Retry").text = _text("retry","Try again")
	set_state("ready")
	_select(_selection)
	_filter("")
	_arrange()

func selection() -> Dictionary:
	for entry in _entries:
		if str(entry.id) == _selection and bool(entry.get("available", true)): return entry.duplicate(true)
	return {}

func focus_search() -> void:
	_search.grab_focus()

func set_state(state: String, message: String = "") -> void:
	_state = state
	_search.editable = state == "ready"
	get_node(BODY+"Status").text = message
	get_node(BODY+"Status").visible = not message.is_empty()
	get_node(BODY+"Retry").visible = state == "error"
	get_node(FOOTER+"Choose").disabled = state != "ready" or selection().is_empty()
	for index in range(_rows.size()):
		_rows[index].disabled = state != "ready" or not bool(_entries[index].get("available",true))
	_list.refresh()

func _select(id: String) -> void:
	_selection = id
	for index in range(_rows.size()):
		var selected := str(_entries[index].id) == id
		_rows[index].set_pressed_no_signal(selected)
		for part in ["Title", "Package"]:
			_rows[index].get_node("Inset/Row/Copy/"+part).add_theme_color_override("font_color", Color("151719") if selected else Color("e7e7dd") if part == "Title" else Color("aebabe"))
	for child in _preview.get_children():
		_preview.remove_child(child)
		child.queue_free()
	var chosen := selection()
	var assigned := not chosen.is_empty() and id != "none"
	_preview.visible = assigned
	get_node(BODY+"Columns/Preview/Empty").visible = not assigned
	get_node(BODY+"Columns/Preview/Empty/Copy/Title").text = _text("empty_preview", "No miniature assigned")
	if assigned: preview_requested.emit(chosen, _preview)
	get_node(FOOTER+"Choose").disabled = _state != "ready" or chosen.is_empty()
	selection_changed.emit(chosen)

func _filter(query: String) -> void:
	var count := 0
	for index in range(_rows.size()):
		var entry := _entries[index]
		var matches := str(entry.id) == "none" or query.is_empty() or (str(entry.get("title", ""))+" "+str(entry.get("package", ""))).to_lower().contains(query.to_lower())
		_rows[index].visible = matches
		if matches and str(entry.id) != "none": count += 1
	get_node(BODY+"Status").visible = count == 0
	get_node(BODY+"Status").text = _text("no_match", "No matching Miniatures.") if not query.is_empty() else _text("empty", "No Miniatures in this World.")
	_list.restore_state({"page":0})
	_list.refresh()

func _arrange() -> void:
	if not is_node_ready(): return
	var phone := size.x <= 900
	var tablet := not phone and size.x <= 1300
	var outer := 8 if phone else 16 if tablet else 32
	var xpad := 12 if phone else 18 if tablet else 32
	var ypad := 8 if phone else 16 if tablet else 24
	for node in [get_node("Frame"),get_node("Linen")]:
		node.position = Vector2(outer,outer + (6 if node.name == "Linen" else 0))
		node.size = size-Vector2(outer*2,outer*2 + (12 if node.name == "Linen" else 0))
	for edge in ["left","right"]: get_node("Inset").add_theme_constant_override("margin_"+edge,outer+xpad)
	for edge in ["top","bottom"]: get_node("Inset").add_theme_constant_override("margin_"+edge,outer+6+ypad)
	get_node("Inset/Layout").add_theme_constant_override("separation",8 if phone else 16)
	get_node("Inset/Layout/Header/Row/Copy").add_theme_constant_override("separation",3 if phone else 6)
	var header: StyleBoxFlat = get_node("Inset/Layout/Header").get_theme_stylebox("panel").duplicate()
	header.content_margin_bottom = 7 if phone else 15
	get_node("Inset/Layout/Header").add_theme_stylebox_override("panel",header)
	var density := "Phone" if phone else "Desktop"
	get_node(HEADER+"Copy/Kicker").theme_type_variation = "SilkCreatureDialogKicker"+density
	get_node(HEADER+"Copy/Title").theme_type_variation = "SilkCreatureAppearanceTitle"+density
	get_node(BODY+"Columns").add_theme_constant_override("separation", 12 if phone else 20)
	get_node(BODY+"Columns/Preview/Empty/Copy").add_theme_constant_override("separation", 6 if phone else 20)
	get_node(BODY+"Columns/Preview/Empty/Copy/Icon").custom_minimum_size = Vector2(28,28) if phone else Vector2(50,50)
	get_node(BODY).add_theme_constant_override("separation", 6 if phone else 12)
	get_node(BODY+"Note").add_theme_font_size_override("font_size",14 if phone else 18)
	get_node(BODY+"Search/Label").add_theme_font_size_override("font_size",16 if phone else 18)
	_search.add_theme_font_size_override("font_size",20)
	get_node(BODY+"Columns/Preview/Empty/Copy/Title").add_theme_font_size_override("font_size",18 if phone else 20)
	for row in _rows:
		row.get_node("Inset/Row/Thumbnail").custom_minimum_size = Vector2(34,34) if phone else Vector2(45,45)
		row.custom_minimum_size.y = 52 if phone else 64
		row.get_node("Inset/Row/Copy/Title").add_theme_font_size_override("font_size",18 if phone else 20)
		row.get_node("Inset/Row/Copy/Package").add_theme_font_size_override("font_size",14 if phone else 16)
		_line_height(row.get_node("Inset/Row/Copy/Title"), 21.6 if phone else 24.0)
		_line_height(row.get_node("Inset/Row/Copy/Package"), 18.2 if phone else 20.8)
	_settle_layout()
	_line_height(get_node(BODY+"Note"), 18.2 if phone else 23.4)
	_line_height(get_node(BODY+"Columns/Preview/Empty/Copy/Title"), 23.4 if phone else 26.0)
	_list.refresh()

func _settle_layout() -> void:
	_layout_frames = 3
	_list.enabled = false
	set_process(true)

func _process(_delta: float) -> void:
	if _layout_frames <= 0: return
	_layout_frames -= 1
	if _layout_frames == 1: _measure_rows()
	if _layout_frames == 0:
		_list.enabled = true
		set_process(false)

func _measure_rows() -> void:
	for row in _rows:
		row.custom_minimum_size.y = maxf(52 if size.x <= 900 else 64, row.get_node("Inset").get_combined_minimum_size().y)
	_list.refresh()

func _text(key: String, fallback: String) -> String:
	return str(_labels.get(key, fallback))

func _line_height(label: Label, line_height: float) -> void:
	var font: FontVariation = label.get_theme_font("font").duplicate()
	font.spacing_top = 0
	font.spacing_bottom = 0
	var difference := roundi(line_height) - ceili(font.get_height(label.get_theme_font_size("font_size")))
	font.spacing_top = floori(difference / 2.0)
	font.spacing_bottom = difference - font.spacing_top
	label.add_theme_font_override("font", font)
