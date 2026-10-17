@tool
extends VBoxContainer
## A retained label/input relationship. The host owns validation and values.
const Focus = preload("res://rookframe/ui/_internal/interaction/focus.gd")
@export var label_text := "":
	set(value):
		label_text = value
		_refresh()
@export_multiline var help_text := "":
	set(value):
		help_text = value
		_refresh()
@export_multiline var error_text := "":
	set(value):
		error_text = value
		_refresh()
@export var label_visible := true:
	set(value):
		label_visible = value
		_refresh()
var _target: Control
var _original: Dictionary = {}

func _ready() -> void:
	_refresh()

func get_input_slot() -> Container:
	return %InputSlot

func set_target(control: Control) -> bool:
	if control != null and (not is_instance_valid(control) or not get_input_slot().is_ancestor_of(control)):
		return false
	if control == _target:
		return true
	_restore_association()
	_target = control
	if is_instance_valid(_target):
		for key in ["accessibility_name", "accessibility_description", "accessibility_labeled_by_nodes", "accessibility_described_by_nodes"]:
			_original[key] = _target.get(key)
	_refresh()
	return true

func set_error(message: String) -> void:
	error_text = message

func focus_input() -> bool:
	if not is_instance_valid(_target): return false
	return Focus.give(Focus.first(_target))

func _refresh() -> void:
	if not is_node_ready(): return
	%Label.text = label_text
	%Label.visible = label_visible and not label_text.is_empty()
	%Help.text = help_text
	%Help.visible = not help_text.is_empty() and error_text.is_empty()
	%Error.text = tr("Error: %s") % error_text
	%Error.visible = not error_text.is_empty()
	if not is_instance_valid(_target): return
	_target.accessibility_name = label_text
	_target.accessibility_description = help_text + ("\n" if not help_text.is_empty() and not error_text.is_empty() else "") + (tr("Error: %s") % error_text if not error_text.is_empty() else "")
	_target.accessibility_labeled_by_nodes = [_target.get_path_to(%Label)]
	var descriptions: Array[NodePath] = []
	if not help_text.is_empty(): descriptions.append(_target.get_path_to(%Help))
	if not error_text.is_empty(): descriptions.append(_target.get_path_to(%Error))
	_target.accessibility_described_by_nodes = descriptions

func _restore_association() -> void:
	if is_instance_valid(_target):
		for key in _original: _target.set(key, _original[key])
	_original.clear()
	_target = null

func _exit_tree() -> void:
	_restore_association()
