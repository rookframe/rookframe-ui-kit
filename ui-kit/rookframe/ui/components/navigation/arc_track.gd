@tool
extends Container

## Places direct child Controls in source order along a circular arc around
## `pivot` and draws the rail they sit on. Entries that do not fit the sweep
## overflow: they are hidden until the track scrolls to them, and an arrowhead
## marks each scrollable end. Children keep their parent, index and connections.

signal scrolled(first_index: int)
signal highlighted(entry: Control)

@export var pivot := Vector2.ZERO:
	set(value):
		pivot = value
		_relayout()

@export_range(24.0, 2048.0, 1.0, "suffix:px") var radius := 160.0:
	set(value):
		radius = value
		_relayout()

## Screen degrees: 0 points right and 90 points down. The sweep runs from start
## to end, so an end below the start runs counter-clockwise.
@export_range(-720.0, 720.0, 1.0, "suffix:°") var start_angle := 180.0:
	set(value):
		start_angle = value
		_relayout()

@export_range(-720.0, 720.0, 1.0, "suffix:°") var end_angle := 360.0:
	set(value):
		end_angle = value
		_relayout()

enum Alignment { BEGIN, CENTER, END }

## Where entries that fit gather along the sweep; overflowing tracks fill it.
@export var alignment := Alignment.BEGIN:
	set(value):
		alignment = value
		_relayout()

## Gap between neighbouring entries, measured along the arc.
@export_range(0.0, 256.0, 1.0, "suffix:px") var spacing := 8.0:
	set(value):
		spacing = value
		_relayout()

## Index, among shown entries, of the first entry on the rail.
@export_range(0, 4096) var first_index := 0:
	set(value):
		value = maxi(0, value)
		if value == first_index:
			return
		first_index = value
		_relayout()

## Emphasises the rail, for example while this track holds focus.
@export var active := false:
	set(value):
		active = value
		queue_redraw()

## Presentation progress from 0 (gathered at the start) to 1 (laid out).
@export_range(0.0, 1.0, 0.01) var reveal := 1.0:
	set(value):
		reveal = clampf(value, 0.0, 1.0)
		_relayout()

var _overflowed: Array[Control] = []
var _arranging := false
var _scrollable := [false, false]


func _ready() -> void:
	child_entered_tree.connect(_child_entered)
	child_exiting_tree.connect(_child_exiting)
	for child in get_children():
		_child_entered(child)


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_SORT_CHILDREN:
			_arrange()
		NOTIFICATION_THEME_CHANGED:
			queue_redraw()


func _get_minimum_size() -> Vector2:
	# Cover the whole ring from the local origin so ordinary containers reserve it.
	var reach := radius + _largest_extent()
	var bounds := Rect2(pivot, Vector2.ZERO)
	for point in _arc_points(reach, 24):
		bounds = bounds.expand(point)
	return Vector2(maxf(0.0, bounds.end.x), maxf(0.0, bounds.end.y))


## Entries in source order, including those currently overflowed.
func get_entries() -> Array[Control]:
	var entries: Array[Control] = []
	for child in get_children():
		if child is Control and not child.top_level and not child.is_queued_for_deletion() \
				and (child.visible or child in _overflowed):
			entries.append(child)
	return entries


## Entries currently placed on the rail.
func get_placed_entries() -> Array[Control]:
	var placed: Array[Control] = []
	for entry in get_entries():
		if entry not in _overflowed:
			placed.append(entry)
	return placed


## -1 asks about the start of the sweep, 1 about its end.
func can_scroll(direction: int) -> bool:
	return _scrollable[0 if direction < 0 else 1]


func scroll_by(steps: int) -> bool:
	var target := clampi(first_index + steps, 0, maxi(0, get_entries().size() - 1))
	if steps > 0 and not can_scroll(1):
		return false
	if target == first_index:
		return false
	first_index = target
	_arrange()
	scrolled.emit(first_index)
	return true


## Scrolls until `entry` is on the rail. Returns false for a foreign entry.
func ensure_visible(entry: Control) -> bool:
	var index := get_entries().find(entry)
	if index < 0:
		return false
	_arrange()
	if index < first_index:
		first_index = index
		_arrange()
		scrolled.emit(first_index)
	var moved := false
	while entry in _overflowed and first_index < index:
		first_index += 1
		_arrange()
		moved = true
	if moved:
		scrolled.emit(first_index)
	return true


## Moves focus `steps` entries along the track from `from`, scrolling as needed.
func step_focus(from: Control, steps: int) -> Control:
	var entries := get_entries()
	var index := entries.find(from)
	if index < 0:
		return null
	var target := index
	var direction := signi(steps)
	var remaining := absi(steps)
	var probe := index
	while remaining > 0:
		probe += direction
		if probe < 0 or probe >= entries.size():
			break
		if entries[probe].focus_mode != FOCUS_NONE and not (entries[probe] is BaseButton and entries[probe].disabled):
			target = probe
			remaining -= 1
	if target == index:
		return null
	ensure_visible(entries[target])
	entries[target].grab_focus()
	return entries[target]


func _relayout() -> void:
	update_minimum_size()
	queue_sort()
	queue_redraw()


func _child_entered(child: Node) -> void:
	if not child is Control:
		return
	child.gui_input.connect(_entry_input.bind(child))
	child.focus_entered.connect(_entry_highlighted.bind(child))
	child.mouse_entered.connect(_entry_highlighted.bind(child))
	child.minimum_size_changed.connect(update_minimum_size)
	update_minimum_size()


func _child_exiting(child: Node) -> void:
	if not child is Control:
		return
	child.gui_input.disconnect(_entry_input.bind(child))
	child.focus_entered.disconnect(_entry_highlighted.bind(child))
	child.mouse_entered.disconnect(_entry_highlighted.bind(child))
	child.minimum_size_changed.disconnect(update_minimum_size)
	_overflowed.erase(child)
	update_minimum_size()


func _entry_highlighted(entry: Control) -> void:
	highlighted.emit(entry)


func _entry_input(event: InputEvent, entry: Control) -> void:
	var steps := 0
	if event.is_action_pressed(&"ui_left", true, true):
		steps = -1
	elif event.is_action_pressed(&"ui_right", true, true):
		steps = 1
	if steps != 0:
		step_focus(entry, steps)
		entry.accept_event()
		return
	var wheel := event as InputEventMouseButton
	if wheel != null and wheel.pressed and wheel.button_index in [MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN]:
		scroll_by(-1 if wheel.button_index == MOUSE_BUTTON_WHEEL_UP else 1)
		entry.accept_event()


func _arrange() -> void:
	if _arranging:
		return
	_arranging = true
	var entries := get_entries()
	first_index = mini(first_index, maxi(0, entries.size() - 1))
	var direction := 1.0 if end_angle >= start_angle else -1.0
	var length := absf(deg_to_rad(end_angle - start_angle)) * radius
	var cursor := 0.0
	var placed: Array[Control] = []
	var overflowed: Array[Control] = []
	for index in entries.size():
		var entry := entries[index]
		var extent := _extent(entry)
		# Placement is contiguous: once one entry overflows, every later one does.
		if index < first_index or placed.size() + first_index < index or cursor + extent > length + 0.5:
			overflowed.append(entry)
			continue
		placed.append(entry)
		cursor += extent + spacing
	const LEADS: Array[float] = [0.0, 0.5, 1.0]
	cursor = maxf(0.0, length - (cursor - spacing)) * LEADS[alignment] if overflowed.is_empty() else 0.0
	for entry in placed:
		var extent := _extent(entry)
		var travel := (cursor + extent * 0.5) * reveal
		var angle := deg_to_rad(start_angle) + direction * travel / radius
		var center := pivot + Vector2.from_angle(angle) * radius
		var entry_size := entry.get_combined_minimum_size()
		fit_child_in_rect(entry, Rect2(center - entry_size * 0.5, entry_size))
		cursor += extent + spacing
	for entry in _overflowed:
		if is_instance_valid(entry) and entry not in overflowed:
			entry.visible = true
	for entry in overflowed:
		entry.visible = false
	_overflowed = overflowed
	_scrollable = [first_index > 0, first_index + placed.size() < entries.size()]
	_arranging = false
	queue_redraw()


func _draw() -> void:
	var points := _arc_points(radius, maxi(8, ceili(absf(end_angle - start_angle) / 3.0)))
	var color := _color(&"rail_active_color" if active else &"rail_color")
	var width := float(_constant(&"rail_width", 2))
	if width > 0.0:
		draw_polyline(points, color, width, true)
	var core := float(_constant(&"rail_core_width", 0))
	if core > 0.0:
		draw_polyline(points, _color(&"rail_core_color"), core, true)
	var direction := 1.0 if end_angle >= start_angle else -1.0
	for end in 2:
		if not _scrollable[end]:
			continue
		var angle := deg_to_rad(end_angle if end == 1 else start_angle)
		var tip := pivot + Vector2.from_angle(angle) * radius
		# Arrowheads point along the tangent, away from the rail.
		var outward := Vector2.from_angle(angle + direction * PI * 0.5) * (1.0 if end == 1 else -1.0)
		_draw_arrow(tip, outward, color)


func _draw_arrow(tip: Vector2, outward: Vector2, color: Color) -> void:
	if has_theme_icon(&"arrow"):
		var texture := get_theme_icon(&"arrow")
		draw_set_transform(tip, outward.angle())
		draw_texture(texture, -Vector2(texture.get_width() * 0.5, texture.get_height() * 0.5), color)
		draw_set_transform_matrix(Transform2D.IDENTITY)
		return
	var length := float(_constant(&"arrow_size", 10))
	var side := outward.orthogonal() * length * 0.5
	draw_colored_polygon(PackedVector2Array([tip + outward * length, tip + side, tip - side]), color)


func _arc_points(at_radius: float, steps: int) -> PackedVector2Array:
	var points := PackedVector2Array()
	for step in steps + 1:
		var angle := deg_to_rad(lerpf(start_angle, end_angle, float(step) / steps))
		points.append(pivot + Vector2.from_angle(angle) * at_radius)
	return points


func _extent(entry: Control) -> float:
	var entry_size := entry.get_combined_minimum_size()
	return maxf(entry_size.x, entry_size.y)


func _largest_extent() -> float:
	var largest := 0.0
	for entry in get_entries():
		largest = maxf(largest, _extent(entry) * 0.5)
	return largest


func _color(item: StringName) -> Color:
	if has_theme_color(item):
		return get_theme_color(item)
	# Native fallback: the default Theme's own button text roles.
	match item:
		&"rail_active_color":
			return get_theme_color(&"font_focus_color", &"Button")
		&"rail_core_color":
			return get_theme_color(&"font_disabled_color", &"Button")
	return get_theme_color(&"font_disabled_color", &"Button")


func _constant(item: StringName, fallback: int) -> int:
	return get_theme_constant(item) if has_theme_constant(item) else fallback
