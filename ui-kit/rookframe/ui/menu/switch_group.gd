@tool
extends MarginContainer
## Shared material tray and adaptive layout. Hosts still own native ButtonGroups.
@export var compact := false:
	set(value):
		compact = value
		_refresh()
var _fit_pending := false


func _ready() -> void:
	resized.connect(_queue_fit)
	theme_changed.connect(_refresh, CONNECT_DEFERRED)
	$Inset/Options.minimum_size_changed.connect(_queue_fit)
	$Inset/Options.child_entered_tree.connect(_child_added)
	$Inset/Options.child_exiting_tree.connect(func(_child: Node) -> void: _queue_fit())
	_refresh()


func set_compact(enabled: bool) -> void:
	compact = enabled


func get_options() -> BoxContainer:
	return $Inset/Options


func _child_added(_child: Node) -> void:
	_refresh.call_deferred()


func _refresh() -> void:
	if not is_node_ready():
		return
	var suffix := "__compact" if compact else ""
	$Inset.theme_type_variation = "components_switch_group" + suffix
	$Inset/Options.theme_type_variation = "components_switch_options" + suffix
	for child in get_options().get_children():
		if child.has_method("set_compact"):
			child.set_compact(compact)
	_queue_fit()


func _queue_fit() -> void:
	if not _fit_pending:
		_fit_pending = true
		_fit.call_deferred()


func _fit() -> void:
	_fit_pending = false
	var options := get_options()
	var count := 0
	var width := float(options.get_theme_constant("minimum_option_width"))
	for child in options.get_children():
		if child is Control and child.visible and not child.is_set_as_top_level():
			count += 1
			width = maxf(width, child.get_combined_minimum_size().x)
	var available: float = size.x - $Inset.get_theme_constant("margin_left") - $Inset.get_theme_constant("margin_right")
	var row_width := count * width + maxi(0, count - 1) * options.get_theme_constant("separation")
	# Stack at equality too: a native row can temporarily hold its parent's minimum.
	options.vertical = count > 1 and available <= row_width


func _enter_tree() -> void:
	preload("res://rookframe/ui/_internal/presentation/binding.gd").attach(self)
