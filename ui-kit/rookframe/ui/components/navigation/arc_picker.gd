@tool
extends Control

## Two-level radial choice opened at a point: categories on the inner track,
## previewed items on the outer track and a caption hub at the pivot. Callers
## own records, previews, what choosing means and when the picker closes.

signal category_changed(category_id: String)
signal highlight_changed(entry: Dictionary)
signal choose_requested(entry: Dictionary)
signal cancel_requested
signal closed

const Entry = preload("res://rookframe/ui/_internal/navigation/arc_entry.gd")
const EntryScene = preload("res://rookframe/ui/_internal/navigation/arc_entry.tscn")

@export_range(48.0, 1024.0, 1.0, "suffix:px") var inner_radius := 96.0:
	set(value):
		inner_radius = value
		_orient()

@export_range(48.0, 2048.0, 1.0, "suffix:px") var outer_radius := 176.0:
	set(value):
		outer_radius = value
		_orient()

## Screen degrees shared by both tracks; see ArcTrack.
@export_range(-720.0, 720.0, 1.0, "suffix:°") var start_angle := 190.0:
	set(value):
		start_angle = value
		_orient()

@export_range(-720.0, 720.0, 1.0, "suffix:°") var end_angle := 350.0:
	set(value):
		end_angle = value
		_orient()

## Mirrors the sweep, then clamps the pivot, so the rings stay on screen.
@export var fit_to_viewport := true

@export_range(0.0, 256.0, 1.0, "suffix:px") var viewport_margin := 16.0

## A press outside every entry closes the picker without consuming the press.
@export var close_on_outside_click := true

@export var animate_open := true
@export var reduced_motion := false

var _categories: Array[Dictionary] = []
var _entries: Array[Dictionary] = []
var _labels: Dictionary = {}
var _category_id := ""
var _selected_id := ""
var _highlight: Dictionary = {}
var _mirror := Vector2.ONE
var _tween: Tween
var _category_group := ButtonGroup.new()
var _item_group := ButtonGroup.new()
var _opened_frame := -1


func _ready() -> void:
	%Categories.highlighted.connect(_highlighted)
	%Items.highlighted.connect(_highlighted)
	%Caption.resized.connect(_place_caption)
	set_process_input(false)
	_orient()
	_refresh_caption()


## categories: {id, title, icon}. entries: {id, title, preview, category or
## categories, disabled}. Previews may mix flat swatches and rendered tiles.
func configure(categories: Array[Dictionary], entries: Array[Dictionary], selected_id: String = "", labels: Dictionary = {}) -> void:
	_categories = categories.duplicate(true)
	_entries = entries.duplicate(true)
	_labels = labels.duplicate(true)
	_selected_id = selected_id
	var initial := ""
	for entry in _entries:
		if entry.get("id", "") == selected_id:
			var owners := _owners(entry)
			initial = owners[0] if not owners.is_empty() else ""
			break
	if initial.is_empty() and not _categories.is_empty():
		initial = _categories[0].get("id", "")
	_build_categories()
	_category_id = ""
	select_category(initial, false)


func select_category(category_id: String, notify: bool = true) -> bool:
	var found := false
	for category in _categories:
		found = found or category.get("id", "") == category_id
	if not found:
		return false
	if category_id == _category_id:
		return true
	_category_id = category_id
	for button in %Categories.get_children():
		if button is Entry:
			button.set_pressed_no_signal(button.entry_id == category_id)
			if button.entry_id == category_id:
				%Categories.ensure_visible(button)
	_build_items()
	_refresh_caption()
	if notify:
		category_changed.emit(category_id)
	return true


func current_category() -> String:
	return _category_id


func selected_id() -> String:
	return _selected_id


## Marks the chosen entry without emitting; hosts confirm what choosing applied.
func set_selected(entry_id: String) -> void:
	_selected_id = entry_id
	for button in %Items.get_children():
		if button is Entry:
			button.set_pressed_no_signal(button.entry_id == entry_id)
			button._refresh_marker()
	_refresh_caption()


func get_category_track() -> Container:
	return %Categories


func get_item_track() -> Container:
	return %Items


## Opens with the pivot at `at`, in the parent's coordinates.
func open_at(at: Vector2) -> void:
	position = at
	_opened_frame = Engine.get_process_frames()
	show()
	_orient()
	set_process_input(close_on_outside_click)
	var target := _selected_button()
	if target == null:
		target = _first_enabled(%Items)
	if target == null:
		target = _first_enabled(%Categories)
	if target != null:
		if target.get_parent() == %Items:
			%Items.ensure_visible(target)
		target.grab_focus()
	if _tween != null:
		_tween.kill()
	if animate_open and not reduced_motion:
		modulate.a = 0.0
		%Categories.reveal = 0.0
		%Items.reveal = 0.0
		_tween = create_tween().set_parallel().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		_tween.tween_property(self, ^"modulate:a", 1.0, 0.12)
		_tween.tween_property(%Categories, ^"reveal", 1.0, 0.18)
		_tween.tween_property(%Items, ^"reveal", 1.0, 0.22)
	else:
		_settle()


func close() -> void:
	if not visible:
		return
	_settle()
	set_process_input(false)
	hide()
	closed.emit()


func is_open() -> bool:
	return visible


func _settle() -> void:
	if _tween != null:
		_tween.kill()
		_tween = null
	modulate.a = 1.0
	%Categories.reveal = 1.0
	%Items.reveal = 1.0


func _input(event: InputEvent) -> void:
	var press := event as InputEventMouseButton
	# The press that opened the picker is not an outside click.
	if press == null or not press.pressed or not visible or Engine.get_process_frames() == _opened_frame:
		return
	if press.button_index not in [MOUSE_BUTTON_LEFT, MOUSE_BUTTON_RIGHT, MOUSE_BUTTON_MIDDLE]:
		return
	for track in [%Categories, %Items]:
		for button in track.get_placed_entries():
			if button.get_global_rect().has_point(press.global_position):
				return
	close()
	cancel_requested.emit()


func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed(&"ui_cancel"):
		get_viewport().set_input_as_handled()
		close()
		cancel_requested.emit()


func _build_categories() -> void:
	for button in %Categories.get_children():
		%Categories.remove_child(button)
		button.queue_free()
	for category in _categories:
		var button := _entry_button(Entry.Kind.CATEGORY, category, _category_group)
		button.icon = category.get("icon")
		button.toggled.connect(func(on: bool):
			if on: select_category(button.entry_id))
		# Keyboard focus follows the category, as a pointer press does.
		button.focus_entered.connect(func():
			if not button.button_pressed: button.button_pressed = true)
		button.gui_input.connect(_track_input.bind(button, %Items))
		%Categories.add_child(button)
	%Categories.first_index = 0


func _build_items() -> void:
	for button in %Items.get_children():
		%Items.remove_child(button)
		button.queue_free()
	# A removed item's highlight must not outlive it in the caption.
	if _highlight in _entries:
		_highlight = {}
	for entry in _entries:
		if _category_id not in _owners(entry):
			continue
		var button := _entry_button(Entry.Kind.ITEM, entry, _item_group)
		button.preview = entry.get("preview")
		button.button_pressed = button.entry_id == _selected_id
		button.pressed.connect(_choose.bind(button.entry_id))
		button.gui_input.connect(_track_input.bind(button, %Categories))
		%Items.add_child(button)
	%Items.first_index = 0
	var selected := _selected_button()
	if selected != null:
		%Items.ensure_visible(selected)


func _entry_button(kind: Entry.Kind, record: Dictionary, group: ButtonGroup) -> Entry:
	var button: Entry = EntryScene.instantiate()
	button.kind = kind
	button.entry_id = record.get("id", "")
	button.title = record.get("title", "")
	button.disabled = record.get("disabled", false)
	button.button_group = group
	button.mouse_exited.connect(_unhighlighted.bind(button))
	return button


# Up moves outward to the items, Down inward to the categories.
func _track_input(event: InputEvent, button: Entry, other: Container) -> void:
	var outward := other == %Items
	if not event.is_action_pressed(&"ui_up" if outward else &"ui_down", true, true):
		return
	var target: Control = _selected_button() if outward else _category_button()
	if target == null or target.get_parent() != other:
		target = _first_enabled(other)
	if target != null:
		other.ensure_visible(target)
		target.grab_focus()
	button.accept_event()


func _choose(entry_id: String) -> void:
	_selected_id = entry_id
	for button in %Items.get_children():
		if button is Entry:
			button._refresh_marker()
	_refresh_caption()
	choose_requested.emit(_record(_entries, entry_id))


func _highlighted(button: Control) -> void:
	if not button is Entry:
		return
	var records := _entries if button.kind == Entry.Kind.ITEM else _categories
	var record := _record(records, button.entry_id)
	if record == _highlight:
		return
	_highlight = record
	_refresh_caption()
	highlight_changed.emit(record.duplicate())


func _unhighlighted(button: Entry) -> void:
	if _highlight.get("id", "") != button.entry_id:
		return
	var focused := get_viewport().gui_get_focus_owner() if is_inside_tree() else null
	if focused is Entry and focused != button and is_ancestor_of(focused):
		_highlighted(focused)
		return
	_highlight = {}
	_refresh_caption()
	highlight_changed.emit({})


func _refresh_caption() -> void:
	if not is_node_ready():
		return
	var category := _record(_categories, _category_id)
	var title := ""
	if not _highlight.is_empty() and _highlight != category:
		title = _highlight.get("title", "")
	elif %Items.get_entries().is_empty():
		title = _labels.get("empty", "Nothing here yet")
	else:
		for entry in _entries:
			if entry.get("id", "") == _selected_id and _category_id in _owners(entry):
				title = entry.get("title", "")
	if not _highlight.is_empty() and _highlight != category and _highlight in _categories:
		category = _highlight
	%Kicker.text = category.get("title", "")
	%Kicker.visible = not %Kicker.text.is_empty()
	%Title.text = title
	%Title.visible = not title.is_empty()
	%Caption.visible = %Kicker.visible or %Title.visible
	_place_caption()


func _place_caption() -> void:
	%Caption.reset_size()
	%Caption.position = -%Caption.size * 0.5


# Mirroring keeps source order and radius; only the side the rings open toward changes.
func _orient() -> void:
	if not is_node_ready():
		return
	_mirror = Vector2.ONE
	if fit_to_viewport and is_inside_tree() and visible:
		var bounds := get_viewport_rect().grow(-viewport_margin)
		var best := -1.0
		for mirror in [Vector2.ONE, Vector2(-1, 1), Vector2(1, -1), Vector2(-1, -1)]:
			var reach := _reach(mirror).intersection(bounds).get_area()
			if reach > best + 0.5:
				best = reach
				_mirror = mirror
		var rings := _reach(_mirror)
		var shift := Vector2(
			maxf(0.0, bounds.position.x - rings.position.x) - maxf(0.0, rings.end.x - bounds.end.x),
			maxf(0.0, bounds.position.y - rings.position.y) - maxf(0.0, rings.end.y - bounds.end.y))
		global_position += shift
	for pair in [[%Categories, inner_radius], [%Items, outer_radius]]:
		pair[0].pivot = Vector2.ZERO
		pair[0].radius = pair[1]
		pair[0].start_angle = _mirrored(start_angle)
		pair[0].end_angle = _mirrored(end_angle)


func _mirrored(angle: float) -> float:
	# Linear reflections keep the sweep length and source order.
	match _mirror:
		Vector2(-1, 1): return 180.0 - angle
		Vector2(1, -1): return -angle
		Vector2(-1, -1): return angle + 180.0
	return angle


func _reach(mirror: Vector2) -> Rect2:
	var origin := global_position
	var bounds := Rect2(origin, Vector2.ZERO)
	var extent := 0.0
	for track in [%Categories, %Items]:
		for entry in track.get_entries():
			var entry_size: Vector2 = entry.get_combined_minimum_size()
			extent = maxf(extent, maxf(entry_size.x, entry_size.y) * 0.5)
	for step in 25:
		var angle := deg_to_rad(lerpf(start_angle, end_angle, step / 24.0))
		var direction := Vector2.from_angle(angle) * mirror
		bounds = bounds.expand(origin + direction * (outer_radius + extent))
		bounds = bounds.expand(origin + direction * maxf(0.0, inner_radius - extent))
	return bounds.merge(Rect2(origin - %Caption.size * 0.5, %Caption.size))


func _selected_button() -> Entry:
	for button in %Items.get_children():
		if button is Entry and button.entry_id == _selected_id:
			return button
	return null


func _category_button() -> Entry:
	for button in %Categories.get_children():
		if button is Entry and button.entry_id == _category_id:
			return button
	return null


func _first_enabled(track: Container) -> Control:
	for button in track.get_entries():
		if button is BaseButton and not button.disabled:
			return button
	return null


static func _owners(entry: Dictionary) -> Array:
	if entry.has("categories"):
		return Array(entry.categories)
	return [entry.get("category", "")]


static func _record(records: Array[Dictionary], record_id: String) -> Dictionary:
	for record in records:
		if record.get("id", "") == record_id:
			return record
	return {}
