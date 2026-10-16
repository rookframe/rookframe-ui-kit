@tool
extends "res://rookframe/ui/components/surfaces/fullscreen_wizard.gd"

func _fit() -> void:
	if not is_node_ready(): return
	var phone := is_compact()
	var tablet := is_tablet()
	var outer := 12 if phone else 16 if tablet else 28
	get_node(^"Ledger").hide()
	get_node(^"StageSurface").hide()
	var layout: Control = get_node(^"Layout")
	layout.offset_left = outer + 12
	layout.offset_right = -outer - 12
	layout.offset_top = outer + 6
	layout.offset_bottom = -outer - 8
	get_node(^"Layout").add_theme_constant_override("separation", 10 if phone else 20)
	get_node(^"Layout/Header").custom_minimum_size.y = 32 if phone else 56 if tablet else 64
	get_node(^"Layout/Steps").custom_minimum_size.y = 4 if phone else 56 if tablet else 68
	get_node(^"Layout/Footer").custom_minimum_size.y = 52 if phone else 60 if tablet else 68
	for path in [^"Layout/Header", ^"Layout/Steps", ^"Layout/Footer"]:
		get_node(path).add_theme_constant_override("margin_left", 0)
		get_node(path).add_theme_constant_override("margin_right", 20)
	get_node(^"Layout/Body").add_theme_constant_override("separation", 16 if phone else 20 if tablet else 28)
	get_context_slot().custom_minimum_size.x = 208 if phone else 246 if tablet else 336
	for edge in ["left", "right", "top", "bottom"]:
		get_context_slot().add_theme_constant_override("margin_" + edge, 12 if edge == "right" else 4 if phone else 8)
		get_stage_slot().add_theme_constant_override("margin_" + edge, 4 if phone else 8)
	get_node(^"Layout/Header/Title").visible = not phone
	get_node(^"Layout/Header/Title").add_theme_font_size_override("font_size", 26 if tablet else 32)
	get_node(^"Layout/Header/Row/CurrentStep").visible = phone
	get_node(^"Layout/Header/Row/CurrentStep").add_theme_font_size_override("font_size", 16)
	get_node(^"Layout/Header/Row/Icon").custom_minimum_size = Vector2(24, 24) if phone else Vector2(32, 32)
	get_node(^"Layout/Header/Row/Brand/Name").add_theme_font_size_override("font_size", 20 if phone else 22 if tablet else 24)
	get_node(^"Layout/Header/Row/Brand/Subtitle").add_theme_font_size_override("font_size", 14 if tablet else 16)
	get_node(^"Layout/Header/Row/Brand/Subtitle").visible = not phone
	get_node(^"Layout/Header/Row").add_theme_constant_override("separation", 10)
	get_node(^"Layout/Header/Row/Close").custom_minimum_size = Vector2(44, 44)
	get_node(^"Layout/Steps/Row").add_theme_constant_override("separation", 6)
	get_node(^"Layout/Footer/Row").add_theme_constant_override("separation", 8)
	for action in ["Back", "Restart", "Primary"]:
		get_node("Layout/Footer/Row/" + action).add_theme_font_size_override("font_size", 18 if phone or tablet else 20)
	for step in _steps:
		step.get_node(^"Row").visible = not phone
		step.get_node(^"Row/Name").add_theme_font_size_override("font_size", 19 if tablet else 24)
		step.get_node(^"Row").offset_top = 12
		step.get_node(^"Row").offset_bottom = -12
		step.get_node(^"Row").add_theme_constant_override("separation", 8)
		step.get_node(^"Row/Marker").custom_minimum_size = Vector2(26,26) if tablet else Vector2(30,30)
		step.get_node(^"Row/Marker/Number").add_theme_font_size_override("font_size", 16 if tablet else 18)
		step.get_node(^"Row").offset_left = 10
		step.get_node(^"Row").offset_right = -10
		step.get_node(^"Rule").offset_top = -2
		_label_line_height(step.get_node(^"Row/Name"), 1.2)
	_fit_primary()
	set_step(_index)
	_fit_surfaces.call_deferred()

func _fit_primary() -> void:
	for name in ["Back", "Primary", "Close", "Restart"]:
		var action := get_node(("Layout/Header/Row/" if name == "Close" else "Layout/Footer/Row/") + name) as Button
		if name in ["Back", "Close"]: action.theme_type_variation = "SilkIcon"
		action.custom_minimum_size = Vector2(44 if name in ["Back", "Close"] else 0, 44)
		action.add_theme_constant_override("icon_max_width", 22)
		for state in ["normal", "hover", "pressed", "disabled"]:
			var frame := action.get_theme_stylebox(state).duplicate() as StyleBoxFlat
			frame.content_margin_left = 0 if name in ["Back", "Close"] else 18
			frame.content_margin_right = frame.content_margin_left
			frame.content_margin_top = 4
			frame.content_margin_bottom = 4
			action.add_theme_stylebox_override(state, frame)

func _draw() -> void:
	if not is_node_ready(): return
	var context := get_context_slot()
	var start := context.global_position - global_position + Vector2(context.size.x, 4)
	draw_line(start, start + Vector2(0, context.size.y - 8), Color("bc927747"))

func _label_line_height(label: Control, multiplier: float) -> void:
	preload("res://rookframe/ui/theme/silkbound_line_height.gd").apply(label, multiplier)

const INK := Color("151719")
const TEXT := Color("e7e7dd")
const MUTED := Color("aebabe")
const NEUTRAL := Color("ceccb3")

func _style_step(step: Control, number: int, index: int) -> void:
	step.get_node(^"Row/Name").add_theme_color_override("font_color", TEXT if number <= index else MUTED)
	step.get_node(^"Row/Marker/Number").add_theme_color_override("font_color", TEXT if number == index else MUTED)
	step.get_node(^"Row/Marker/Done").self_modulate = TEXT
	var frame := step.get_node(^"Row/Marker").get_theme_stylebox("panel").duplicate() as StyleBoxFlat
	frame.bg_color = Color("bc92771c") if number == index else Color.TRANSPARENT
	frame.border_color = NEUTRAL if number <= index else Color("3e4346")
	step.get_node(^"Row/Marker").add_theme_stylebox_override("panel", frame)
	step.get_node(^"Rule").color = NEUTRAL if number == index else MUTED if number < index else Color("3e4346")

func _style_primary_state(button: Button) -> void:
	button.modulate.a = 0.4 if button.disabled else 1.0
