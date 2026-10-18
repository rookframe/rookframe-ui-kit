@tool
extends RefCounted
## Main-menu materials and motion, applied to the retained shared Button.
const Appearance = preload("res://rookframe/ui/_internal/presentation/appearance.gd")
const CarvedStyle = preload("button_style.gd")
const SLOTS = {
	BaseButton.DRAW_NORMAL: "normal", BaseButton.DRAW_HOVER: "hover",
	BaseButton.DRAW_PRESSED: "pressed", BaseButton.DRAW_HOVER_PRESSED: "hover_pressed",
	BaseButton.DRAW_DISABLED: "disabled",
}
const FACE_PROPERTIES = ["expand_margin_top", "expand_margin_bottom", "content_margin_top", "content_margin_bottom"]
var style: StyleBox
var targets: Dictionary
var mode: int
var face_from: Dictionary
var face_elapsed := 0.0
var face_seconds := 0.0
var reveal_from := 0.0
var reveal_target := 0.0
var reveal_elapsed := 0.0

func _configure_button(control: Button) -> void:
	style = null
	targets = {}
	if control.get_theme_constant("texture_visible") == 0:
		return
	for slot in SLOTS.values():
		targets[slot] = control.get_theme_stylebox(slot)
	mode = control.get_draw_mode()
	if not targets[SLOTS[mode]] is StyleBoxFlat:
		return
	style = CarvedStyle.new()
	style.face = targets[SLOTS[mode]].duplicate()
	style.configure(control)
	face_seconds = 0.0
	face_elapsed = 0.0
	face_from = {}
	reveal_target = _reveal(control)
	style.reveal = reveal_target
	reveal_from = reveal_target
	reveal_elapsed = 0.0
	control.begin_bulk_theme_override()
	for slot in SLOTS.values():
		if targets[slot] is StyleBoxFlat and not control.has_theme_stylebox_override(slot):
			Appearance.override_item(control, "styles", slot, style)
	# Let Godot shape the engraved label alongside its native icon and alignment.
	if not control.has_theme_constant_override("outline_size"):
		Appearance.override_item(control, "constants", &"outline_size", control.get_theme_constant("groove_size"))
	if not control.has_theme_color_override("font_outline_color"):
		Appearance.override_item(control, "colors", &"font_outline_color", control.get_theme_color("groove_color"))
	control.end_bulk_theme_override()
	_process_button(control, 0.0)
	control.queue_redraw()

func _process_button(control: Button, delta: float) -> void:
	if style == null:
		return
	var changed := false
	var next_mode := control.get_draw_mode()
	if next_mode != mode:
		var was_pressed := mode in [BaseButton.DRAW_PRESSED, BaseButton.DRAW_HOVER_PRESSED]
		mode = next_mode
		var timing := "press_ms" if mode in [BaseButton.DRAW_PRESSED, BaseButton.DRAW_HOVER_PRESSED] else "release_ms" if was_pressed else "hover_ms"
		face_seconds = control.get_theme_constant(timing) / 1000.0
		face_elapsed = 0.0
		face_from = {}
		for property in FACE_PROPERTIES:
			face_from[property] = style.face.get(property)
	face_elapsed += delta
	if targets[SLOTS[mode]] is StyleBoxFlat:
		for property in FACE_PROPERTIES:
			var target: float = targets[SLOTS[mode]].get(property)
			var value := _interpolate(control, face_from.get(property, target), target, face_elapsed, face_seconds)
			if not is_equal_approx(style.face.get(property), value):
				style.face.set(property, value)
				changed = true
	var next_reveal := _reveal(control)
	if not is_equal_approx(next_reveal, reveal_target):
		reveal_from = style.reveal
		reveal_target = next_reveal
		reveal_elapsed = 0.0
	reveal_elapsed += delta
	var reveal := _interpolate(control, reveal_from, reveal_target, reveal_elapsed, control.get_theme_constant("ornament_ms") / 1000.0)
	var tint := control.get_theme_color("rest_tint") if mode == BaseButton.DRAW_NORMAL and not control.has_focus() else control.get_theme_color("cap_tint")
	if not is_equal_approx(style.reveal, reveal) or style.tint != tint:
		style.reveal = reveal
		style.tint = tint
		changed = true
	if changed:
		style.sync_margins()
		control.queue_redraw()

func _reveal(control: Button) -> float:
	if control.disabled:
		return 0.0
	if control.has_focus() or control.get_draw_mode() in [BaseButton.DRAW_HOVER, BaseButton.DRAW_HOVER_PRESSED]:
		return 1.0
	return control.get_theme_constant("ornament_rest") / 100.0

func _interpolate(control: Button, from: float, to: float, elapsed: float, seconds: float) -> float:
	if control.reduced_motion or seconds <= 0 or elapsed >= seconds:
		return to
	return Tween.interpolate_value(from, to - from, elapsed, seconds, control.get_theme_constant("transition"), control.get_theme_constant("ease"))
