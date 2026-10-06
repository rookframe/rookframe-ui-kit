extends Control
## A fixed-page notepad composed with native TextEdit and Label shaping.
## The value is always the complete text. Reparent get_pager() into the footer.
signal value_changed(value: String)
@export_multiline var value := "":
	set(next):
		value = next
		_pending = true
@export var compact := false:
	set(next):
		compact = next
		_pending = true
var _pages: Array[String] = [""]
var _page := 0
var _pending := true
var _setting := false
var _caret := -1
@onready var _editor: TextEdit = get_node(^"Editor")
@onready var _measure: Label = get_node(^"Measure")
@onready var _pager: HBoxContainer = get_node(^"Pager")

func _ready() -> void:
	_editor.text_changed.connect(_changed)
	resized.connect(func(): _pending = true)
	get_node(^"Pager/Previous").pressed.connect(_turn.bind(-1))
	get_node(^"Pager/Next").pressed.connect(_turn.bind(1))

func get_pager() -> HBoxContainer:
	if _pager.get_parent() == self:
		remove_child(_pager)
	return _pager

func _process(_delta: float) -> void:
	if _pending and size.x > 0 and size.y > 0:
		_pending = false
		_reflow()

func _changed() -> void:
	if _setting:
		return
	var prefix := ""
	for index in _page:
		prefix += _pages[index]
	var suffix := ""
	for index in range(_page + 1, _pages.size()):
		suffix += _pages[index]
	_caret = prefix.length() + _editor.get_caret_column()
	for line in _editor.get_caret_line():
		_caret += _editor.get_line(line).length() + 1
	value = prefix + _editor.text + suffix
	value_changed.emit(value)

func _reflow() -> void:
	var font_size := 16 if compact else 20
	var line_spacing := 6 if compact else 10
	_editor.add_theme_font_size_override("font_size", font_size)
	_editor.add_theme_constant_override("line_spacing", line_spacing)
	_measure.add_theme_font_override("font", _editor.get_theme_font("font"))
	_measure.add_theme_font_size_override("font_size", font_size)
	_measure.add_theme_constant_override("line_spacing", line_spacing)
	var frame := _editor.get_theme_stylebox("normal")
	var width := maxf(1, size.x - frame.get_minimum_size().x - 2)
	var height := maxf(1, size.y - frame.get_minimum_size().y - 2)
	_pages.clear()
	var start := 0
	while start < value.length():
		var low := 1
		var high := value.length() - start
		var best := 1
		while low <= high:
			var count := (low + high) / 2
			_measure.text = value.substr(start, count)
			_measure.size = Vector2(width, 0)
			if _measure.get_minimum_size().y <= height:
				best = count
				low = count + 1
			else:
				high = count - 1
		var end := start + best
		if end < value.length():
			var boundary := maxi(value.rfind("\n", end - 1), value.rfind(" ", end - 1))
			if boundary > start + best * 0.65:
				end = boundary + 1
		_pages.append(value.substr(start, end - start))
		start = end
	if _pages.is_empty():
		_pages.append("")
	if _caret >= 0:
		var offset := 0
		_page = _pages.size() - 1
		for index in _pages.size():
			if _caret <= offset + _pages[index].length():
				_page = index
				break
			offset += _pages[index].length()
	_page = clampi(_page, 0, _pages.size() - 1)
	_show_page()

func _turn(step: int) -> void:
	if _pending:
		_pending = false
		_reflow()
	_page = clampi(_page + step, 0, _pages.size() - 1)
	_caret = -1
	_show_page()

func _show_page() -> void:
	_setting = true
	_editor.text = _pages[_page]
	if _caret >= 0:
		var offset := 0
		for index in _page:
			offset += _pages[index].length()
		var before := _pages[_page].substr(0, maxi(0, _caret - offset)).split("\n")
		_editor.set_caret_line(before.size() - 1)
		_editor.set_caret_column(before[-1].length())
	_editor.scroll_vertical = 0
	_editor.scroll_horizontal = 0
	_setting = false
	_caret = -1
	_pager.get_node(^"Previous").disabled = _page == 0
	_pager.get_node(^"Next").disabled = _page == _pages.size() - 1
	_pager.get_node(^"Range").text = "%d / %d" % [_page + 1, _pages.size()]
