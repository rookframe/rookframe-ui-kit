@tool
extends Control
## Silkbound full-screen task frame. Consumers own the draft and task content.
signal back_requested
signal restart_requested
signal primary_requested
signal close_requested

const STEP = preload("res://rookframe/ui/_internal/surfaces/wizard_step.tscn")
const INK := Color("151719")
const TEXT := Color("e7e7dd")
const MUTED := Color("aebabe")
const NEUTRAL := Color("ceccb3")
var _steps: Array[Control] = []
var _index := 0
var _primary_icon_only := false
var _primary_text := "Continue"
var _hint := "Results stay with you when you go back."

func _ready() -> void:
	get_node(^"Layout/Footer/Row/Back").pressed.connect(func(): back_requested.emit())
	get_node(^"Layout/Footer/Row/Restart").pressed.connect(func(): restart_requested.emit())
	get_node(^"Layout/Footer/Row/Primary").pressed.connect(func(): primary_requested.emit())
	get_node(^"Layout/Header/Row/Close").pressed.connect(func(): close_requested.emit())
	resized.connect(_fit)
	get_stage_slot().resized.connect(_fit_surfaces)
	get_stage_slot().item_rect_changed.connect(_fit_surfaces)
	_fit()

func configure(brand: String, title: String, steps: Array[String], labels: Dictionary = {}) -> void:
	get_node(^"Layout/Header/Row/Brand/Name").text = brand
	get_node(^"Layout/Header/Title").text = title
	get_node(^"Layout/Header/Row/Brand/Subtitle").text = str(labels.get("subtitle", "Character creation"))
	get_node(^"Layout/Footer/Row/Back").accessibility_name = str(labels.get("back", "Back"))
	get_node(^"Layout/Footer/Row/Back").tooltip_text = str(labels.get("back", "Back"))
	get_node(^"Layout/Footer/Row/Restart").text = str(labels.get("restart", "Start over"))
	_hint = str(labels.get("hint", "Results stay with you when you go back."))
	get_node(^"Layout/Header/Row/Close").accessibility_name = str(labels.get("close", "Close character creation"))
	get_node(^"Layout/Header/Row/Close").tooltip_text = str(labels.get("close", "Close character creation"))
	for child in _steps:
		child.get_parent().remove_child(child)
		child.queue_free()
	_steps.clear()
	for index in steps.size():
		var step := STEP.instantiate() as Control
		step.get_node(^"Row/Marker/Number").text = str(index + 1)
		step.get_node(^"Row/Name").text = steps[index]
		get_node(^"Layout/Steps/Row").add_child(step)
		_steps.append(step)
	set_step(_index)
	_fit()

func set_step(index: int) -> void:
	_index = index
	for number in _steps.size():
		var step := _steps[number]
		step.get_node(^"Row/Name").add_theme_color_override("font_color", TEXT if number <= index else MUTED)
		step.get_node(^"Row/Marker/Number").add_theme_color_override("font_color", INK if number == index else MUTED)
		step.get_node(^"Row/Marker/Done").self_modulate = TEXT
		var frame := step.get_node(^"Row/Marker").get_theme_stylebox("panel").duplicate() as StyleBoxFlat
		frame.bg_color = NEUTRAL if number == index else INK
		frame.border_color = NEUTRAL if number <= index else Color("3e4346")
		step.get_node(^"Row/Marker").add_theme_stylebox_override("panel", frame)
		step.get_node(^"Row/Marker/Number").visible = number >= index
		step.get_node(^"Row/Marker/Done").visible = number < index
		step.get_node(^"Rule").color = NEUTRAL if number == index else MUTED if number < index else Color("3e4346")
		step.get_node(^"Rule").visible = is_compact() or number == index
		step.get_node(^"Connector").visible = not is_compact() and number < index - 1
	get_node(^"Layout/Footer/Row/Back").disabled = index == 0
	if not _steps.is_empty():
		get_node(^"Layout/Header/Row/CurrentStep").text = "%02d / %02d · %s" % [index + 1, _steps.size(), _steps[index].get_node(^"Row/Name").text]

func set_primary(text: String, disabled: bool, icon: Texture2D = null, icon_only: bool = false) -> void:
	_primary_text = text
	_primary_icon_only = icon_only
	var button := get_node(^"Layout/Footer/Row/Primary") as Button
	button.text = "" if icon_only else text
	button.accessibility_name = text
	button.tooltip_text = text if icon_only else ""
	button.disabled = disabled
	button.modulate.a = 0.4 if disabled else 1.0
	button.icon = icon
	_fit_primary()

func set_back_enabled(enabled: bool) -> void:
	get_node(^"Layout/Footer/Row/Back").disabled = not enabled

func get_context_slot() -> MarginContainer:
	return get_node(^"Layout/Body/ContextSlot")

func get_stage_slot() -> MarginContainer:
	return get_node(^"Layout/Body/StageSlot")

func is_compact() -> bool:
	return size.y <= 560 or size.x <= 740

func is_tablet() -> bool:
	return size.x <= 1300 and not is_compact()

func _fit() -> void:
	if not is_node_ready():
		return
	var phone := is_compact()
	var tablet := is_tablet()
	var short_window := tablet and size.y <= 740
	var outer := 8 if phone else 16 if tablet else 32
	var horizontal := 8 if phone else 18 if tablet else 32
	var vertical := 4 if phone else 12 if short_window else 14 if tablet else 24
	var inner := 10 if phone else 12 if tablet else 24
	var inner_vertical := 6 if phone or short_window else inner
	get_node(^"Ledger").position = Vector2(outer, outer)
	get_node(^"Ledger").size = size - Vector2(outer, outer) * 2
	get_node(^"Ledger/Ribbon").visible = not phone
	get_node(^"Ledger/Ribbon").offset_left = -40 if tablet else -60
	get_node(^"Ledger/Ribbon").offset_right = -20 if tablet else -32
	get_node(^"Ledger/Ribbon").offset_bottom = 68 if tablet else 100
	var layout := get_node(^"Layout") as Control
	layout.offset_left = outer + horizontal
	layout.offset_right = -outer - horizontal
	layout.offset_top = outer + 6
	layout.offset_bottom = -outer - 6
	get_node(^"Layout/Header").custom_minimum_size.y = 44 if phone else 52 if short_window else 60 if tablet else 76
	get_node(^"Layout/Steps").custom_minimum_size.y = 4 if phone else 64 if short_window else 72 if tablet else 80
	get_node(^"Layout/Footer").custom_minimum_size.y = 48 if phone else 52 if short_window else 60 if tablet else 72
	for path in [^"Layout/Header", ^"Layout/Steps", ^"Layout/Footer"]:
		for edge in ["left", "right"]:
			get_node(path).add_theme_constant_override("margin_" + edge, 0)
	get_node(^"Layout/Header").add_theme_constant_override("margin_right", 0 if phone else 40 if tablet else 64)
	get_node(^"Layout/Body").add_theme_constant_override("separation", 16 if phone else 18 if tablet else 32)
	get_context_slot().custom_minimum_size.x = 218 if phone else 246 if tablet else 336
	for edge in ["left", "right", "top", "bottom"]:
		get_context_slot().add_theme_constant_override("margin_" + edge, 0 if edge == "left" else (13 if phone else 15 if tablet else 29) if edge == "right" else vertical + (4 if phone and edge == "top" else 0))
		get_stage_slot().add_theme_constant_override("margin_" + edge, inner + 1 if edge in ["left", "right"] else vertical + inner_vertical + 1)
	get_node(^"Layout/Header/Title").visible = not phone
	get_node(^"Layout/Header/Title").add_theme_font_size_override("font_size", 29 if tablet else 40)
	get_node(^"Layout/Header/Row/CurrentStep").visible = phone
	get_node(^"Layout/Header/Row/CurrentStep").add_theme_font_size_override("font_size", 18)
	get_node(^"Layout/Header/Row/Icon").custom_minimum_size = Vector2(24, 24) if phone else Vector2(32, 32)
	get_node(^"Layout/Header/Row/Brand/Name").add_theme_font_size_override("font_size", 20 if phone else 22 if tablet else 24)
	get_node(^"Layout/Header/Row/Brand/Subtitle").add_theme_font_size_override("font_size", 14 if tablet else 16)
	get_node(^"Layout/Header/Row/Brand").add_theme_constant_override("separation", 3)
	get_node(^"Layout/Header/Row").add_theme_constant_override("separation", 12)
	get_node(^"Layout/Header/Row/Close").custom_minimum_size = Vector2(44, 44)
	get_node(^"Layout/Steps/Row").add_theme_constant_override("separation", 4 if phone else 0)
	get_node(^"Layout/Footer/Row").add_theme_constant_override("separation", 8 if phone else 16)
	for action in ["Back", "Restart", "Primary"]:
		get_node("Layout/Footer/Row/" + action).add_theme_font_size_override("font_size", 18 if phone or tablet else 20)
	get_node(^"Layout/Header/Row/Brand/Subtitle").visible = not phone
	for step in _steps:
		step.get_node(^"Row").visible = not phone
		step.get_node(^"Row/Name").add_theme_font_size_override("font_size", 17 if tablet else 18)
		step.get_node(^"Row").offset_top = 8 if tablet else 12
		step.get_node(^"Connector").offset_top = 23 if tablet else 27
		step.get_node(^"Connector").offset_bottom = 24 if tablet else 28
		step.get_node(^"Rule").offset_top = -4 if phone else -3
	for pair in [["Layout/Header/Title", 1.2], ["Layout/Header/Row/Brand/Name", 1.1], ["Layout/Header/Row/Brand/Subtitle", 1.4]]:
		_label_line_height(get_node(pair[0]), pair[1])
	for step in _steps:
		_label_line_height(step.get_node(^"Row/Name"), 1.2)
	for path in ["Layout/Header/Row/Close", "Layout/Footer/Row/Back", "Layout/Footer/Row/Restart", "Layout/Footer/Row/Primary"]:
		_label_line_height(get_node(path), 1.2)
	_fit_primary()
	set_step(_index)
	_fit_surfaces.call_deferred()

func _fit_primary() -> void:
	var phone := is_compact()
	var tablet := is_tablet()
	get_node(^"Layout/Footer/Row/Primary").custom_minimum_size = Vector2(44 if _primary_icon_only else 144 if phone else 152 if tablet else 180, 44)
	for name in ["Back", "Primary", "Close"]:
		var action := get_node(("Layout/Header/Row/" if name == "Close" else "Layout/Footer/Row/") + name) as Button
		for state in ["normal", "hover", "pressed", "disabled"]:
			var frame := action.get_theme_stylebox(state).duplicate() as StyleBoxFlat
			frame.content_margin_left = 0 if name in ["Back", "Close"] or _primary_icon_only else 10 if phone else 16
			frame.content_margin_right = frame.content_margin_left
			action.add_theme_stylebox_override(state, frame)
	get_node(^"Layout/Footer/Row/Hint").text = _primary_text if _primary_icon_only else _hint
	get_node(^"Layout/Footer/Row/Hint").visible = _primary_icon_only or not phone and not tablet
	get_node(^"Layout/Footer/Row/Hint").add_theme_font_size_override("font_size", 18 if phone or not _primary_icon_only else 21)
	get_node(^"Layout/Footer/Row/Hint").add_theme_color_override("font_color", TEXT if _primary_icon_only else MUTED)

func _fit_surfaces() -> void:
	if not is_node_ready():
		return
	var vertical := 4 if is_compact() else 12 if is_tablet() and size.y <= 740 else 14 if is_tablet() else 24
	var slot := get_stage_slot()
	get_node(^"StageSurface").position = slot.global_position - global_position + Vector2(0, vertical)
	get_node(^"StageSurface").size = slot.size - Vector2(0, vertical * 2)
	queue_redraw()

func _draw() -> void:
	if not is_node_ready():
		return
	var layout := get_node(^"Layout") as Control
	var header := get_node(^"Layout/Header") as Control
	var steps := get_node(^"Layout/Steps") as Control
	var footer := get_node(^"Layout/Footer") as Control
	var line := Color("3e4346")
	for y in [header.position.y + header.size.y, steps.position.y + steps.size.y, footer.position.y]:
		draw_line(layout.position + Vector2(0, y), layout.position + Vector2(layout.size.x, y), line)
	var context := get_context_slot()
	var vertical := 4 if is_compact() else 14 if is_tablet() else 24
	var start := context.global_position - global_position + Vector2(context.size.x, vertical)
	draw_line(start, start + Vector2(0, context.size.y - vertical * 2), line)
	if not is_compact():
		var center := layout.position + Vector2(layout.size.x * 0.5, header.size.y)
		var points := PackedVector2Array([center + Vector2(0,-4), center + Vector2(4,0), center + Vector2(0,4), center + Vector2(-4,0), center + Vector2(0,-4)])
		draw_colored_polygon(points, INK)
		draw_polyline(points, Color("bc9277"), 1, true)

func _label_line_height(label: Control, multiplier: float) -> void:
	preload("res://rookframe/ui/theme/silkbound_line_height.gd").apply(label, multiplier)
