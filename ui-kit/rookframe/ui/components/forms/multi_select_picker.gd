extends VBoxContainer
## Stable-ID multiple selection; native ChoiceRows own activation and focus.
signal selection_changed(ids: PackedStringArray)
const ROW = preload("res://rookframe/ui/components/forms/choice_row.tscn")
const Focus = preload("res://rookframe/ui/_internal/interaction/focus.gd")
@export var show_summary := true:
	set(value):
		show_summary = value
		_refresh()
@export var show_clear := true:
	set(value):
		show_clear = value
		_refresh()
@export var disabled := false:
	set(value):
		disabled = value
		_refresh()
@export var focus_fallback: Control
var _items: Array[Dictionary] = []
var _selected: Dictionary = {}
var _rows: Dictionary = {}
var _removes: Dictionary = {}

func _ready() -> void:
	%Clear.pressed.connect(_clear_selection)
	_refresh()

func set_items(items: Array[Dictionary]) -> bool:
	var ids: Dictionary = {}
	for item in items:
		if not item.get("id") is String or item.id.is_empty() or ids.has(item.id): return false
		if not item.get("title") is String or item.title.is_empty(): return false
		if not item.get("description", "") is String or not item.get("disabled", false) is bool: return false
		if item.get("icon") != null and not item.icon is Texture2D: return false
		ids[item.id] = true
	_items = items.duplicate(true)
	for id in _selected.keys():
		if not ids.has(id): _selected.erase(id)
	_refresh()
	return true

func set_selected_ids(ids: PackedStringArray) -> bool:
	var selected: Dictionary = {}
	var known: Dictionary = {}
	for item in _items: known[item.id] = true
	for id in ids:
		if selected.has(id) or not known.has(id): return false
		selected[id] = true
	_selected = selected
	_refresh()
	return true

func get_selected_ids() -> PackedStringArray:
	var result := PackedStringArray()
	for item in _items:
		if _selected.has(item.id): result.append(item.id)
	return result

func _change(id: String, selected: bool) -> void:
	if disabled: return
	for item in _items:
		if item.id == id:
			if item.get("disabled", false): return
			if selected == _selected.has(id): return
			if selected: _selected[id] = true
			else: _selected.erase(id)
			_refresh()
			selection_changed.emit(get_selected_ids())
			return

func _clear_selection() -> void:
	if disabled: return
	var before := get_selected_ids()
	for item in _items:
		if not item.get("disabled", false): _selected.erase(item.id)
	if before == get_selected_ids(): return
	_refresh()
	selection_changed.emit(get_selected_ids())

func _refresh() -> void:
	if not is_node_ready(): return
	var focused := get_viewport().gui_get_focus_owner()
	var old_rows := %Rows.get_children()
	var old_removes := %Summary.get_children()
	var focus_index := old_rows.find(focused)
	var remove_index := old_removes.find(focused)
	var live: Dictionary = {}
	for index in _items.size():
		var item := _items[index]
		var id: String = item.id
		live[id] = true
		if not _rows.has(id):
			var row = ROW.instantiate()
			%Rows.add_child(row)
			_connect_row(row, id)
			_rows[id] = row
		var row = _rows[id]
		%Rows.move_child(row, index)
		row.title = item.title
		row.description = item.get("description", "")
		row.icon = item.get("icon")
		row.disabled = disabled or item.get("disabled", false)
		row.focus_mode = Control.FOCUS_NONE if row.disabled else Control.FOCUS_ALL
		row.set_pressed_no_signal(_selected.has(id))
		# ChoiceRow refresh reads the native pressed state without emitting.
		row.action_label = tr("Select")
		if _selected.has(id) and not _removes.has(id):
			var remove := Button.new()
			remove.custom_minimum_size = Vector2(44, 44)
			remove.pressed.connect(func(): _change(id, false))
			%Summary.add_child(remove)
			_removes[id] = remove
		if _removes.has(id):
			var remove: Button = _removes[id]
			remove.text = tr("Remove %s") % item.title
			remove.accessibility_name = remove.text
			remove.disabled = row.disabled
			remove.focus_mode = Control.FOCUS_NONE if remove.disabled else Control.FOCUS_ALL
	for id in _rows.keys():
		if not live.has(id): _remove_control(_rows, id)
	for id in _removes.keys():
		if not live.has(id) or not _selected.has(id): _remove_control(_removes, id)
	var position := 0
	for item in _items:
		if _removes.has(item.id):
			%Summary.move_child(_removes[item.id], position)
			position += 1
	%Summary.visible = show_summary
	%Clear.visible = show_clear
	%Clear.text = tr("Clear selection")
	%Clear.disabled = disabled or not _has_removable()
	%Clear.focus_mode = Control.FOCUS_NONE if %Clear.disabled else Control.FOCUS_ALL
	%Empty.visible = _items.is_empty()
	%Empty.text = tr("No options")
	if focused != null and not Focus.eligible(focused):
		if remove_index >= 0: Focus.restore(%Summary.get_children(), remove_index, focus_fallback)
		elif focus_index >= 0: Focus.restore(%Rows.get_children(), focus_index, focus_fallback)
		elif focused == %Clear: Focus.restore(%Rows.get_children(), 0, focus_fallback)

func _connect_row(row: Button, id: String) -> void:
	row.toggled.connect(func(selected: bool): _change(id, selected))

func _has_removable() -> bool:
	for item in _items:
		if _selected.has(item.id) and not item.get("disabled", false): return true
	return false

func _remove_control(mapping: Dictionary, id: String) -> void:
	var control: Control = mapping[id]
	control.get_parent().remove_child(control)
	control.queue_free()
	mapping.erase(id)
