@tool
extends RefCounted
const Appearance = preload("res://rookframe/ui/_internal/presentation/appearance.gd")


const INK := Color("151719")
const TEXT := Color("e7e7dd")
const MUTED := Color("aebabe")
const NEUTRAL := Color("ceccb3")

func _fit(control) -> void:
	if not control.is_node_ready(): return
	var phone = control.is_compact()
	var tablet = control.is_tablet()
	var outer = 12 if phone else 16 if tablet else 28
	Appearance.write(control.get_node(^"Ledger"), ^"visible", false)
	Appearance.write(control.get_node(^"StageSurface"), ^"visible", false)
	var layout: Control = control.get_node(^"Layout")
	Appearance.write(layout, ^"offset_left", outer + 12)
	Appearance.write(layout, ^"offset_right", -outer - 12)
	Appearance.write(layout, ^"offset_top", outer + 6)
	Appearance.write(layout, ^"offset_bottom", -outer - 8)
	Appearance.override_item(control.get_node(^"Layout"), "constants", "separation", 10 if phone else 20)
	Appearance.write(control.get_node(^"Layout/Header"), ^"custom_minimum_size:y", 32 if phone else 56 if tablet else 64)
	Appearance.write(control.get_node(^"Layout/Steps"), ^"custom_minimum_size:y", 4 if phone else 56 if tablet else 68)
	Appearance.write(control.get_node(^"Layout/Footer"), ^"custom_minimum_size:y", 52 if phone else 60 if tablet else 68)
	for path in [^"Layout/Header", ^"Layout/Steps", ^"Layout/Footer"]:
		Appearance.override_item(control.get_node(path), "constants", "margin_left", 0)
		Appearance.override_item(control.get_node(path), "constants", "margin_right", 20)
	Appearance.override_item(control.get_node(^"Layout/Body"), "constants", "separation", 16 if phone else 20 if tablet else 28)
	Appearance.write(control.get_context_slot(), ^"custom_minimum_size:x", 208 if phone else 246 if tablet else 336)
	for edge in ["left", "right", "top", "bottom"]:
		Appearance.override_item(control.get_context_slot(), "constants", "margin_" + edge, 12 if edge == "right" else 4 if phone else 8)
		Appearance.override_item(control.get_stage_slot(), "constants", "margin_" + edge, 4 if phone else 8)
	Appearance.write(control.get_node(^"Layout/Header/Title"), ^"visible", not phone)
	Appearance.override_item(control.get_node(^"Layout/Header/Title"), "font_sizes", "font_size", 26 if tablet else 32)
	Appearance.write(control.get_node(^"Layout/Header/Row/CurrentStep"), ^"visible", phone)
	Appearance.override_item(control.get_node(^"Layout/Header/Row/CurrentStep"), "font_sizes", "font_size", 16)
	Appearance.write(control.get_node(^"Layout/Header/Row/Icon"), ^"custom_minimum_size", Vector2(24, 24) if phone else Vector2(32, 32))
	Appearance.override_item(control.get_node(^"Layout/Header/Row/Brand/Name"), "font_sizes", "font_size", 20 if phone else 22 if tablet else 24)
	Appearance.override_item(control.get_node(^"Layout/Header/Row/Brand/Subtitle"), "font_sizes", "font_size", 14 if tablet else 16)
	Appearance.write(control.get_node(^"Layout/Header/Row/Brand/Subtitle"), ^"visible", not phone)
	Appearance.override_item(control.get_node(^"Layout/Header/Row"), "constants", "separation", 10)
	Appearance.write(control.get_node(^"Layout/Header/Row/Close"), ^"custom_minimum_size", Vector2(44, 44))
	Appearance.override_item(control.get_node(^"Layout/Steps/Row"), "constants", "separation", 6)
	Appearance.override_item(control.get_node(^"Layout/Footer/Row"), "constants", "separation", 8)
	for action in ["Back", "Restart", "Primary"]:
		Appearance.override_item(control.get_node("Layout/Footer/Row/" + action), "font_sizes", "font_size", 18 if phone or tablet else 20)
	for step in control._steps:
		Appearance.write(step.get_node(^"Row"), ^"visible", not phone)
		Appearance.override_item(step.get_node(^"Row/Name"), "font_sizes", "font_size", 19 if tablet else 24)
		Appearance.write(step.get_node(^"Row"), ^"offset_top", 12)
		Appearance.write(step.get_node(^"Row"), ^"offset_bottom", -12)
		Appearance.override_item(step.get_node(^"Row"), "constants", "separation", 8)
		Appearance.write(step.get_node(^"Row/Marker"), ^"custom_minimum_size", Vector2(26,26) if tablet else Vector2(30,30))
		Appearance.override_item(step.get_node(^"Row/Marker/Number"), "font_sizes", "font_size", 16 if tablet else 18)
		Appearance.write(step.get_node(^"Row"), ^"offset_left", 10)
		Appearance.write(step.get_node(^"Row"), ^"offset_right", -10)
		Appearance.write(step.get_node(^"Rule"), ^"offset_top", -2)
		control._label_line_height(step.get_node(^"Row/Name"), 1.2)
	control._fit_primary()
	control.set_step(control._index)
	control._fit_surfaces.call_deferred()

func _fit_primary(control) -> void:
	for name in ["Back", "Primary", "Close", "Restart"]:
		var action = control.get_node(("Layout/Header/Row/" if name == "Close" else "Layout/Footer/Row/") + name) as Button
		if name in ["Back", "Close"]: Appearance.write(action, ^"theme_type_variation", "RookframeIcon")
		Appearance.write(action, ^"custom_minimum_size", Vector2(44 if name in ["Back", "Close"] else 0, 44))
		Appearance.override_item(action, "constants", "icon_max_width", 22)
		for state in ["normal", "hover", "pressed", "disabled"]:
			var frame = action.get_theme_stylebox(state).duplicate() as StyleBoxFlat
			Appearance.write(frame, ^"content_margin_left", 0 if name in ["Back", "Close"] else 18)
			Appearance.write(frame, ^"content_margin_right", frame.content_margin_left)
			Appearance.write(frame, ^"content_margin_top", 4)
			Appearance.write(frame, ^"content_margin_bottom", 4)
			Appearance.override_item(action, "styles", state, frame)

func _draw(control) -> void:
	if not control.is_node_ready(): return
	var context = control.get_context_slot()
	var start = context.global_position - control.global_position + Vector2(context.size.x, 4)
	control.draw_line(start, start + Vector2(0, context.size.y - 8), Color("bc927747"))

func _label_line_height(control, label: Control, multiplier: float) -> void:
	preload("res://rookframe/ui/theme/silkbound_line_height.gd").apply(label, multiplier)

func _style_step(control, step: Control, number: int, index: int) -> void:
	Appearance.override_item(step.get_node(^"Row/Name"), "colors", "font_color", TEXT if number <= index else MUTED)
	Appearance.override_item(step.get_node(^"Row/Marker/Number"), "colors", "font_color", TEXT if number == index else MUTED)
	Appearance.write(step.get_node(^"Row/Marker/Done"), ^"self_modulate", TEXT)
	var frame = step.get_node(^"Row/Marker").get_theme_stylebox("panel").duplicate() as StyleBoxFlat
	Appearance.write(frame, ^"bg_color", Color("bc92771c") if number == index else Color.TRANSPARENT)
	Appearance.write(frame, ^"border_color", NEUTRAL if number <= index else Color("3e4346"))
	Appearance.override_item(step.get_node(^"Row/Marker"), "styles", "panel", frame)
	Appearance.write(step.get_node(^"Rule"), ^"color", NEUTRAL if number == index else MUTED if number < index else Color("3e4346"))

func _style_primary_state(control, button: Button) -> void:
	Appearance.write(button, ^"modulate:a", 0.4 if button.disabled else 1.0)
