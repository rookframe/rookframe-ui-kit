@tool
extends Node
## A component's native Theme signal drives its optional presentation.
const Appearance = preload("appearance.gd")
var component: String
static func attach(control: Node) -> void:
	if control.has_meta(&"_presentation_binding"):
		return
	var binding = load("res://rookframe/ui/_internal/presentation/binding.gd").new()
	control.set_meta(&"_presentation_binding", weakref(binding))
	binding.component = control.scene_file_path
	control.add_child(binding, false, Node.INTERNAL_MODE_FRONT)

var _theme: Theme
var _applying := false
var _theme_owner: Node

func _enter_tree() -> void:
	var control := get_parent()
	_theme_owner = control
	while _theme_owner != null and not _theme_owner.has_signal("theme_changed"):
		_theme_owner = _theme_owner.get_parent()
	if _theme_owner != null:
		_theme_owner.theme_changed.connect(_sync)
	control.child_entered_tree.connect(_profile_child)
	_sync()

func _exit_tree() -> void:
	if _theme_owner != null:
		_theme_owner.theme_changed.disconnect(_sync)
	get_parent().child_entered_tree.disconnect(_profile_child)

func _sync() -> void:
	if _applying:
		return
	var control := get_parent()
	var next := Appearance.owning_theme(control)
	if next == _theme:
		return
	_applying = true
	_theme = next
	if control.is_node_ready() and control.has_method("_presentation_will_change"):
		control._presentation_will_change()
	control.remove_meta(&"_presentation_child_theme")
	Appearance.hooks(control)
	Appearance.restore(control)
	if next != null and next.get("presentations") != null:
		var template: PackedScene = next.presentations.get(component)
		if template != null:
			Appearance.apply_template(control, template)
	if control.is_node_ready():
		if control.has_method("_presentation_changed"):
			control._presentation_changed()
		if control is CanvasItem:
			control.queue_redraw()
		if control is Control:
			control.resized.emit()
	_applying = false

func _profile_child(child: Node) -> void:
	Appearance.profile_child(get_parent(), child)
