@tool
extends Button
## One native action control. The consumer Theme supplies semantic appearance.
const Appearance = preload("res://rookframe/ui/_internal/presentation/appearance.gd")

enum Variant { SECONDARY, PRIMARY, DESTRUCTIVE, EMBLEM }
enum Layout { INLINE, STACKED }

const THEME_TYPES: Array[StringName] = [
	&"components_button", &"components_button_primary", &"components_button_destructive",
	&"components_button_emblem",
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

## STACKED places the icon above a wrapping label.
@export var layout := Layout.INLINE:
	set(value):
		layout = value
		_refresh_button()

var _refreshing_button := false
var _managed_minimum := Vector2(44, 44)
var _caller_minimum := Vector2.ZERO
var _fitted_text := ""
# Native properties the content layout currently controls: [caller value, layout value].
var _owned := {}
var _emblem_name_checked := false


func _ready() -> void:
	minimum_size_changed.connect(_content_changed)
	_refresh_button()


func set_compact(enabled: bool) -> void:
	compact = enabled


func _notification(what: int) -> void:
	if what in [NOTIFICATION_THEME_CHANGED, NOTIFICATION_TRANSLATION_CHANGED] and is_node_ready() and not _refreshing_button:
		_refresh_button()


func _validate_property(property: Dictionary) -> void:
	# Layout-controlled values are derived, so scenes keep only the caller's own values.
	if _owned.has(StringName(property.name)):
		property.usage &= ~PROPERTY_USAGE_STORAGE


func _refresh_button() -> void:
	if not is_inside_tree() or _refreshing_button:
		return
	_refreshing_button = true
	# Remove only presentation-owned overrides before resolving the new Theme/role.
	Appearance.restore(self)
	theme_type_variation = StringName(String(THEME_TYPES[variant])
		+ ("__stacked" if layout == Layout.STACKED else "") + ("__compact" if compact else ""))
	_arrange_content()
	_fit_minimum()
	if variant == Variant.EMBLEM and not _emblem_name_checked:
		_emblem_name_checked = true
		# Callers usually name the action after choosing the variant.
		_check_emblem_name.call_deferred()
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


func _content_changed() -> void:
	if _refreshing_button:
		return
	_refreshing_button = true
	_arrange_content()
	if text != _fitted_text:
		_fit_minimum()
	_refreshing_button = false


func _arrange_content() -> void:
	var stacked := layout == Layout.STACKED
	# Icon-only and stacked content centre the icon; stacked labels wrap and are never trimmed.
	_control(&"icon_alignment", HORIZONTAL_ALIGNMENT_CENTER, stacked or (text.is_empty() and icon != null))
	_control(&"vertical_icon_alignment", VERTICAL_ALIGNMENT_TOP, stacked)
	_control(&"autowrap_mode", TextServer.AUTOWRAP_WORD_SMART, stacked)
	_control(&"text_overrun_behavior", TextServer.OVERRUN_NO_TRIMMING, stacked)


func _control(property: StringName, value: Variant, enabled: bool) -> void:
	if enabled:
		if not _owned.has(property):
			_owned[property] = [get(property), value]
			notify_property_list_changed()
		if get(property) != value:
			set(property, value)
	elif _owned.has(property):
		var entry: Array = _owned[property]
		_owned.erase(property)
		# A caller edit made while the layout controlled the value takes priority.
		if get(property) == entry[1]:
			set(property, entry[0])
		notify_property_list_changed()


func _fit_minimum() -> void:
	_fitted_text = text
	var height := 44 if compact else 52
	if has_theme_constant("minimum_height"):
		height = maxi(height, get_theme_constant("minimum_height"))
	var width := float(height)
	if autowrap_mode != TextServer.AUTOWRAP_OFF:
		# Native autowrap reports no label width; keep the widest word whole.
		# Godot wraps inside the current state's margins, so reserve the widest of them.
		var margins := 0.0
		for state in ["normal", "hover", "pressed", "hover_pressed", "disabled"]:
			margins = maxf(margins, get_theme_stylebox(state).get_minimum_size().x)
		width = maxf(width, ceilf(_widest_word() + margins))
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


func _check_emblem_name() -> void:
	if variant == Variant.EMBLEM and accessibility_name.is_empty() and tooltip_text.is_empty():
		push_warning("Button: an EMBLEM action needs an accessibility_name or tooltip_text.")
