@tool
extends Control
## Pages authored native content at measured text/Control boundaries.
## Compose a single Container under Area; no wheel or drag scrolling is used.
var _page := 0
var _pages: Array[Vector2] = [Vector2.ZERO]
var _pending := false
var _content: Control
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
	visibility_changed.connect(refresh)
	_content.minimum_size_changed.connect(refresh)
	get_viewport().gui_focus_changed.connect(_reveal_focus)
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
	_content.size = Vector2(size.x, maxf(height, _content.get_combined_minimum_size().y))
	var overflow := enabled and _content.get_combined_minimum_size().y > height + 1
	get_node(^"Pager").visible = overflow
	if overflow:
		height -= get_node(^"Pager").get_combined_minimum_size().y
	_content.size.y = maxf(height, _content.get_combined_minimum_size().y)
	get_node(^"Area").size = Vector2(size.x, height)
	# Native Containers finish wrapping their children before measuring pages.
	_measure.call_deferred()

func _measure() -> void:
	var height: float = get_node(^"Area").size.y
	_pages.clear()
	if not get_node(^"Pager").visible or height <= 0:
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
	if node is Label:
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
	get_node(^"Pager/Previous").disabled = _page == 0
	get_node(^"Pager/Next").disabled = _page == _pages.size() - 1
	get_node(^"Pager/Range").text = "%d / %d" % [_page + 1, _pages.size()]

func _reveal_focus(control: Control) -> void:
	if not enabled or not _content.is_ancestor_of(control):
		return
	var top := control.global_position.y - _content.global_position.y
	for index in _pages.size():
		if top >= _pages[index].x and top < _pages[index].y:
			_page = index
			_show_page()
			return
