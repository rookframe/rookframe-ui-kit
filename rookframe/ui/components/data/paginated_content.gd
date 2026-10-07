@tool
extends Control
## Pages authored native content at measured text/Control boundaries.
## Compose a single Container under Area; no wheel or drag scrolling is used.
const TEXT_FIELD = preload("res://rookframe/ui/components/forms/text_field.gd")
const TEXT_AREA = preload("res://rookframe/ui/components/forms/text_area.gd")

var _page := 0
var _pages: Array[Vector2] = [Vector2.ZERO]
var _pending := false
var _content: Control
var _focus_viewport: Viewport
var _external_pager := false
@onready var _pager: HBoxContainer = get_node(^"Pager")
@onready var _previous: Button = get_node(^"Pager/Previous")
@onready var _next: Button = get_node(^"Pager/Next")
@onready var _range: Label = get_node(^"Pager/Range")

## Reparent this native pager into an authored fixed footer when needed.
## Its ownership and paging behavior remain with this component.
func get_pager() -> HBoxContainer:
	if _pager.get_parent() == self:
		remove_child(_pager)
	_pager.anchor_top = 0
	_pager.anchor_bottom = 0
	_pager.anchor_right = 0
	_pager.custom_minimum_size = Vector2(0, 44)
	_previous.text = "‹"
	_next.text = "›"
	_previous.tooltip_text = "Previous page"
	_next.tooltip_text = "Next page"
	_previous.accessibility_name = _previous.tooltip_text
	_next.accessibility_name = _next.tooltip_text
	_previous.theme_type_variation = "TaskGlyphButton"
	_next.theme_type_variation = "TaskGlyphButton"
	return _pager

func _enter_tree() -> void:
	_focus_viewport = get_viewport()
	if not _focus_viewport.gui_focus_changed.is_connected(_reveal_focus):
		_focus_viewport.gui_focus_changed.connect(_reveal_focus)

func _exit_tree() -> void:
	if is_instance_valid(_focus_viewport) and _focus_viewport.gui_focus_changed.is_connected(_reveal_focus):
		_focus_viewport.gui_focus_changed.disconnect(_reveal_focus)
@export var always_show_pager := false:
	set(value):
		always_show_pager = value
		refresh()

@export var enabled := true:
	set(value):
		enabled = value
		refresh()

func _ready() -> void:
	if get_node(^"Area").get_child_count() == 0:
		return
	_content = get_node(^"Area").get_child(0) as Control
	get_node(^"Pager/Previous").pressed.connect(func(): _page -= 1; _show_page())
	get_node(^"Pager/Next").pressed.connect(func(): _page += 1; _show_page())
	resized.connect(refresh)
	visibility_changed.connect(_visibility_changed)
	_content.minimum_size_changed.connect(refresh)
	refresh()

func capture_state() -> Dictionary:
	return {"page": _page}

func restore_state(state: Dictionary) -> void:
	_page = maxi(0, int(state.get("page", 0)))
	refresh()

func refresh() -> void:
	if not is_node_ready() or _content == null or _pending:
		return
	_pending = true
	get_tree().process_frame.connect(_fit, CONNECT_ONE_SHOT)

func _fit() -> void:
	_pending = false
	if not is_visible_in_tree():
		return
	var height := size.y
	_external_pager = _pager.get_parent() != self
	_content.size = Vector2(size.x, maxf(height, _content.get_combined_minimum_size().y))
	_pager.alignment = BoxContainer.ALIGNMENT_CENTER if always_show_pager else BoxContainer.ALIGNMENT_BEGIN
	_range.size_flags_horizontal = 0 if always_show_pager else Control.SIZE_EXPAND_FILL
	_range.custom_minimum_size.x = 54 if always_show_pager else 0
	_range.add_theme_font_size_override("font_size", 14 if always_show_pager else 12)
	var overflow := enabled and _content.get_combined_minimum_size().y > height + 1
	_pager.visible = overflow or always_show_pager
	if overflow and not _external_pager:
		height -= _pager.get_combined_minimum_size().y
	_content.size.y = maxf(height, _content.get_combined_minimum_size().y)
	get_node(^"Area").size = Vector2(size.x, height)
	# Native Containers finish wrapping their children before measuring pages.
	_measure.call_deferred()

func _measure() -> void:
	var height: float = get_node(^"Area").size.y
	_pages.clear()
	if not _pager.visible or height <= 0:
		_pages.append(Vector2(0, height))
	else:
		var spans: Array[Vector2] = []
		_collect_spans(_content, spans)
		spans.sort_custom(func(a: Vector2, b: Vector2): return a.x < b.x)
		var start := 0.0
		var total := _content.size.y
		while start < total:
			var end := minf(start + height, total)
			# Back up to a gap shared by every column, without splitting a line
			# or an interactive control. Content is still laid out by Godot.
			for index in range(spans.size() - 1, -1, -1):
				var span := spans[index]
				if span.x < end and span.y > end:
					end = span.x
			if end <= start:
				push_error("PaginatedContent needs a viewport taller than its indivisible content.")
				break
			_pages.append(Vector2(start, end))
			start = end
		if _pages.is_empty():
			_pages.append(Vector2(0, height))
	_show_page()
	var focused := get_viewport().gui_get_focus_owner()
	if focused != null:
		_reveal_focus(focused)

func _collect_spans(node: Control, spans: Array[Vector2]) -> void:
	if not node.is_visible_in_tree():
		return
	var top := node.global_position.y - _content.global_position.y
	if node is TEXT_FIELD or node is TEXT_AREA:
		# A field's label, editor and validation copy are one interaction.
		spans.append(Vector2(floorf(top), ceilf(top + node.size.y)))
		return
	elif node is Label:
		var last := Vector2(-1, -1)
		for character in node.text.length():
			var rect: Rect2 = node.get_character_bounds(character)
			if not rect.has_area():
				continue
			var span := Vector2(floorf(top + rect.position.y), ceilf(top + rect.end.y))
			if span != last:
				spans.append(span)
				last = span
	elif node is RichTextLabel:
		for line in node.get_line_count():
			var offset: float = node.get_line_offset(line)
			spans.append(Vector2(floorf(top + offset), ceilf(top + offset + node.get_line_height(line))))
	elif node is BaseButton or node is TextureRect or node is LineEdit or node is TextEdit or node is Range:
		spans.append(Vector2(floorf(top), ceilf(top + node.size.y)))
		return
	for child in node.get_children():
		if child is Control:
			_collect_spans(child, spans)

func _show_page() -> void:
	_page = clampi(_page, 0, _pages.size() - 1)
	_content.position.y = -_pages[_page].x
	get_node(^"Area").size.y = _pages[_page].y - _pages[_page].x
	_previous.disabled = _page == 0
	_next.disabled = _page == _pages.size() - 1
	_range.text = "%d / %d" % [_page + 1, _pages.size()]

func _reveal_focus(control: Control) -> void:
	if not enabled or _content == null or not _content.is_ancestor_of(control):
		return
	var top := control.global_position.y - _content.global_position.y
	for index in _pages.size():
		if top >= _pages[index].x and top < _pages[index].y:
			_page = index
			_show_page()
			return

func _visibility_changed() -> void:
	if not is_visible_in_tree():
		_pager.hide()
	refresh()
