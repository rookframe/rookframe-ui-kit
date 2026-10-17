@tool
extends Button
## One native action control. The consumer Theme supplies semantic appearance.
const Appearance = preload("res://rookframe/ui/_internal/presentation/appearance.gd")

enum Variant { SECONDARY, PRIMARY, DESTRUCTIVE }

const THEME_TYPES: Array[StringName] = [
	&"components_button", &"components_button_primary", &"components_button_destructive",
]

@export var variant := Variant.SECONDARY:
	set(value):
		variant = value
		_refresh_button()

@export var compact := false:
	set(value):
		compact = value
		_refresh_button()

@export var reduced_motion := false:
	set(value):
		reduced_motion = value
		_refresh_button()

var _refreshing_button := false
var _managed_minimum := Vector2(44, 44)
var _caller_minimum := Vector2.ZERO
var _icon_only := false
var _label_icon_alignment := HORIZONTAL_ALIGNMENT_LEFT


func _ready() -> void:
	minimum_size_changed.connect(_refresh_icon_alignment)
	_refresh_icon_alignment()
	_refresh_button()


func set_compact(enabled: bool) -> void:
	compact = enabled


func _notification(what: int) -> void:
	if what == NOTIFICATION_THEME_CHANGED and is_node_ready() and not _refreshing_button:
		_refresh_button()


func _refresh_button() -> void:
	if not is_inside_tree() or _refreshing_button:
		return
	_refreshing_button = true
	# Remove only presentation-owned overrides before resolving the new Theme/role.
	Appearance.restore(self)
	theme_type_variation = StringName(String(THEME_TYPES[variant]) + ("__compact" if compact else ""))
	var height := 44 if compact else 52
	if has_theme_constant("minimum_height"):
		height = maxi(height, get_theme_constant("minimum_height"))
	# Keep caller-supplied larger minima, while allowing our own density to shrink.
	for axis in 2:
		if custom_minimum_size[axis] != _managed_minimum[axis]:
			_caller_minimum[axis] = custom_minimum_size[axis]
	_managed_minimum = Vector2(maxf(height, _caller_minimum.x), maxf(height, _caller_minimum.y))
	custom_minimum_size = _managed_minimum
	var presented := Appearance.has_hook(self, &"_configure_button")
	if presented:
		Appearance.invoke(self, &"_configure_button")
	set_process(presented and not Engine.is_editor_hint())
	_refreshing_button = false


func _process(delta: float) -> void:
	# Animated Theme item changes must not restart their own transition.
	_refreshing_button = true
	Appearance.invoke(self, &"_process_button", [delta])
	_refreshing_button = false


func _exit_tree() -> void:
	_refreshing_button = true
	Appearance.restore(self)
	_refreshing_button = false


func _refresh_icon_alignment() -> void:
	var icon_only := text.is_empty() and icon != null
	if icon_only == _icon_only:
		return
	_icon_only = icon_only
	if icon_only:
		_label_icon_alignment = icon_alignment
		icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	else:
		icon_alignment = _label_icon_alignment
