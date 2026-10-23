@tool
extends Button
## One native tile: an icon above a permanent label. The consumer Theme supplies appearance.
const Appearance = preload("res://rookframe/ui/_internal/presentation/appearance.gd")

enum Usage { CATEGORY, TOOL, CHOICE }

const THEME_TYPES: Array[StringName] = [
	&"RookframeIconTileCategory", &"RookframeIconTileTool", &"RookframeIconTileChoice",
]

@export var usage := Usage.CATEGORY:
	set(value):
		usage = value
		_refresh_tile()

@export var compact := false:
	set(value):
		compact = value
		_refresh_tile()

var _refreshing_tile := false
var _managed_minimum := Vector2(44, 44)
var _caller_minimum := Vector2.ZERO
var _measured_text := ""
var _automatic_name := ""


func _enter_tree() -> void:
	preload("res://rookframe/ui/_internal/presentation/binding.gd").attach(self)


func _ready() -> void:
	minimum_size_changed.connect(_label_changed)
	_refresh_tile()


func set_compact(enabled: bool) -> void:
	compact = enabled


func _notification(what: int) -> void:
	if what in [NOTIFICATION_THEME_CHANGED, NOTIFICATION_TRANSLATION_CHANGED] and is_node_ready() and not _refreshing_tile:
		_refresh_tile()


func _refresh_tile() -> void:
	if not is_inside_tree() or _refreshing_tile:
		return
	_refreshing_tile = true
	# Remove only presentation-owned overrides before resolving the new Theme/role.
	Appearance.restore(self)
	theme_type_variation = StringName(String(THEME_TYPES[usage]) + ("__compact" if compact else ""))
	if Appearance.has_hook(self, &"_configure_tile"):
		Appearance.invoke(self, &"_configure_tile")
	_fit_label()
	_refreshing_tile = false


func _label_changed() -> void:
	if _refreshing_tile or text == _measured_text:
		return
	_refreshing_tile = true
	_fit_label()
	_refreshing_tile = false


func _fit_label() -> void:
	_measured_text = text
	if accessibility_name.is_empty() or accessibility_name == _automatic_name:
		accessibility_name = text
		_automatic_name = text
	var height := 44
	if has_theme_constant("minimum_height"):
		height = maxi(height, get_theme_constant("minimum_height"))
	# Native autowrap reports no text width; reserve the widest word so wrapping
	# happens between words and the permanent label is never broken or trimmed.
	var width := maxf(height, _widest_word() + get_theme_stylebox("normal").get_minimum_size().x)
	# Keep caller-supplied larger minima, while allowing our own density to shrink.
	for axis in 2:
		if custom_minimum_size[axis] != _managed_minimum[axis]:
			_caller_minimum[axis] = custom_minimum_size[axis]
	_managed_minimum = Vector2(maxf(width, _caller_minimum.x), maxf(height, _caller_minimum.y))
	custom_minimum_size = _managed_minimum


func _widest_word() -> float:
	var font := get_theme_font("font")
	var font_size := get_theme_font_size("font_size")
	var widest := 0.0
	for word in tr(text).split(" ", false):
		widest = maxf(widest, ceilf(font.get_string_size(word, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x))
	return widest


func _exit_tree() -> void:
	_refreshing_tile = true
	Appearance.restore(self)
	_refreshing_tile = false
