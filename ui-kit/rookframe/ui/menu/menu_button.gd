extends Button
## Stock Button owns input, focus, accessible text and its inscription.
## The Theme chooses a textured cap or a native StyleBox face and adornments.
const Usage = preload("menu_usage.gd")
const MenuTheme = preload("menu_theme.gd")
const SLOTS = {
	DRAW_NORMAL: "normal", DRAW_HOVER: "hover", DRAW_PRESSED: "pressed",
	DRAW_HOVER_PRESSED: "hover_pressed", DRAW_DISABLED: "disabled",
}
const FACE_PROPERTIES = ["expand_margin_top", "expand_margin_bottom", "content_margin_top", "content_margin_bottom", "bg_color", "border_color", "shadow_color"]
@export var usage: StringName = Usage.STANDARD
@export var symbol: StringName
var _targets: Dictionary = {}
var _face: StyleBoxFlat
var _motion: Tween
var _ornament_motion: Tween
var _ornament_reveal := 0.0
var _ornament_target := -1.0
var _mode: int = -1
var _configuring := false
var _refresh_pending := false

func _ready() -> void:
	resized.connect(_layout_art)
	set_compact(false)
	_refresh_materials()

func set_compact(enabled: bool) -> void:
	var variant := MenuTheme.button_variant(usage, enabled)
	if theme_type_variation != variant:
		theme_type_variation = variant

func _notification(what: int) -> void:
	if what == NOTIFICATION_THEME_CHANGED and is_node_ready() and not _configuring:
		_refresh_pending = true

func _refresh_materials() -> void:
	_configuring = true
	_refresh_pending = false
	custom_minimum_size.y = maxi(44, get_theme_constant("minimum_height"))
	if _motion:
		_motion.kill()
	if _ornament_motion:
		_ornament_motion.kill()
	_ornament_target = -1.0
	begin_bulk_theme_override()
	for slot in SLOTS.values():
		remove_theme_stylebox_override(slot)
	end_bulk_theme_override()
	for slot in SLOTS.values():
		_targets[slot] = get_theme_stylebox(slot).duplicate()
	_mode = get_draw_mode()
	_face = _targets[SLOTS[_mode]].duplicate()
	var textured := get_theme_constant("texture_visible") != 0
	_face.draw_center = not textured
	begin_bulk_theme_override()
	for slot in SLOTS.values():
		add_theme_stylebox_override(slot, _face)
	end_bulk_theme_override()
	for layer in [$Shadow, $Depth, $Surface]:
		layer.visible = textured
		layer.texture = get_theme_icon("cap")
		layer.patch_margin_left = get_theme_constant("patch_side")
		layer.patch_margin_right = get_theme_constant("patch_side")
		layer.patch_margin_top = get_theme_constant("patch_rail")
		layer.patch_margin_bottom = get_theme_constant("patch_rail")
	$Shadow.self_modulate = get_theme_color("shadow_tint")
	$Depth.self_modulate = get_theme_color("edge_tint")
	$Surface.self_modulate = get_theme_color("cap_tint")
	for layer in [$OrnamentLeft, $OrnamentRight]:
		layer.texture = get_theme_icon("adornment")
		layer.self_modulate = get_theme_color("cap_tint")
	# The transparent underprint supplies the groove around native Button ink.
	$Engraving.add_theme_font_override("font", get_theme_font("font"))
	$Engraving.add_theme_font_size_override("font_size", get_theme_font_size("font_size"))
	$Engraving.add_theme_color_override("font_color", Color.TRANSPARENT)
	$Engraving.add_theme_color_override("font_outline_color", get_theme_color("groove_color"))
	$Engraving.add_theme_color_override("font_shadow_color", get_theme_color("cut_edge_color"))
	$Engraving.add_theme_constant_override("outline_size", get_theme_constant("groove_size"))
	$Engraving.add_theme_constant_override("shadow_offset_x", get_theme_constant("groove_offset_x"))
	$Engraving.add_theme_constant_override("shadow_offset_y", get_theme_constant("groove_offset_y"))
	$Engraving.add_theme_constant_override("shadow_outline_size", get_theme_constant("groove_shadow_size"))
	icon = get_theme_icon("image", MenuTheme.native_type(symbol)) if get_theme_constant("icons_visible") and not symbol.is_empty() else null
	_layout_art()
	_configuring = false

func _layout_art() -> void:
	if _face == null or $Surface.texture == null:
		return
	var cap_height := maxf(1, size.y - get_theme_constant("cap_depth"))
	var texture_height: float = $Surface.texture.get_height()
	var art_scale := cap_height / texture_height
	# Nine-patch end fittings keep their proportions while only the rails stretch.
	for layer in [$Shadow, $Depth, $Surface]:
		layer.scale = Vector2.ONE * art_scale
		layer.size = Vector2(size.x / art_scale, texture_height)
	$Shadow.position.y = get_theme_constant("shadow_drop")
	$Depth.position.y = get_theme_constant("cap_depth")
	$Surface.position.y = -_face.expand_margin_top
	var ornament_size := Vector2(get_theme_constant("ornament_width"), get_theme_constant("ornament_height"))
	var extension := get_theme_constant("ornament_travel") * _ornament_reveal
	var ornament_y := (cap_height - ornament_size.y) / 2 - _face.expand_margin_top
	$OrnamentLeft.size = ornament_size
	$OrnamentRight.size = ornament_size
	$OrnamentLeft.position = Vector2(-extension, ornament_y)
	$OrnamentRight.position = Vector2(size.x - ornament_size.x + extension, ornament_y)
	$OrnamentLeft.visible = _ornament_reveal > 0 and ornament_size.x > 0
	$OrnamentRight.visible = _ornament_reveal > 0 and ornament_size.x > 0
	$Engraving.text = text
	$Engraving.horizontal_alignment = alignment
	$Engraving.position = Vector2(_face.content_margin_left, _face.content_margin_top)
	$Engraving.size = size - Vector2(_face.content_margin_left + _face.content_margin_right, _face.content_margin_top + _face.content_margin_bottom)

func _process(_delta: float) -> void:
	if _refresh_pending:
		_refresh_materials()
	if _face == null:
		return
	if $Engraving.text != text or $Engraving.horizontal_alignment != alignment:
		_layout_art()
	var next_mode := get_draw_mode()
	var selected := has_focus() or next_mode in [DRAW_HOVER, DRAW_HOVER_PRESSED]
	var art_tint := get_theme_color("rest_tint") if next_mode == DRAW_NORMAL and not selected else get_theme_color("cap_tint")
	for layer in [$Surface, $OrnamentLeft, $OrnamentRight]:
		if layer.self_modulate != art_tint:
			layer.self_modulate = art_tint
	var reveal := 0.0 if disabled else 1.0 if selected else get_theme_constant("ornament_rest") / 100.0
	if not is_equal_approx(reveal, _ornament_target):
		_ornament_target = reveal
		if _ornament_motion:
			_ornament_motion.kill()
		_ornament_motion = create_tween().set_trans(get_theme_constant("transition")).set_ease(get_theme_constant("ease"))
		_ornament_motion.tween_method(_set_ornament_reveal, _ornament_reveal, reveal, get_theme_constant("ornament_ms") / 1000.0)
	if next_mode == _mode:
		return
	var was_pressed := _mode in [DRAW_PRESSED, DRAW_HOVER_PRESSED]
	_mode = next_mode
	if _motion:
		_motion.kill()
	var timing := "press_ms" if _mode in [DRAW_PRESSED, DRAW_HOVER_PRESSED] else "release_ms" if was_pressed else "hover_ms"
	var seconds := get_theme_constant(timing) / 1000.0
	var target: StyleBoxFlat = _targets[SLOTS[_mode]]
	_motion = create_tween().set_parallel().set_trans(get_theme_constant("transition")).set_ease(get_theme_constant("ease"))
	for property in FACE_PROPERTIES:
		_motion.tween_method(_set_face_property.bind(property), _face.get(property), target.get(property), seconds)

func _set_face_property(value: Variant, property: String) -> void:
	# Own StyleBox changes must redraw without rebuilding their running animation.
	_configuring = true
	_face.set(property, value)
	_layout_art()
	_configuring = false

func _set_ornament_reveal(value: float) -> void:
	_ornament_reveal = value
	_layout_art()
