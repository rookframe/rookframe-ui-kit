@tool
extends Control
## Silkbound full-screen task frame. Consumers own the draft and task content.
signal back_requested
signal restart_requested
signal primary_requested
signal close_requested

@export var reduced_motion := false:
	set(value):
		reduced_motion = value
		if is_node_ready(): get_node(^"Frame").reduced_motion = value

const STEP = preload("res://rookframe/ui/_internal/surfaces/wizard_step.tscn")
const INK := Color("151719")
const TEXT := Color("e7e7dd")
const MUTED := Color("aebabe")
const NEUTRAL := Color("ceccb3")
var _steps: Array[Control] = []
var _index := 0

func _ready() -> void:
	get_node(^"Frame").reduced_motion = reduced_motion
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
	var changed := _index != index
	_index = index
	if changed and is_node_ready():
		_reveal_stage.call_deferred()
	for number in _steps.size():
		var step := _steps[number]
		step.get_node(^"Row/Name").add_theme_color_override("font_color", TEXT if number <= index else MUTED)
		step.get_node(^"Row/Marker/Number").add_theme_color_override("font_color", TEXT if number == index else MUTED)
		step.get_node(^"Row/Marker/Done").self_modulate = TEXT
		var frame := step.get_node(^"Row/Marker").get_theme_stylebox("panel").duplicate() as StyleBoxFlat
		frame.bg_color = Color("bc92771c") if number == index else Color.TRANSPARENT
		frame.border_color = NEUTRAL if number <= index else Color("3e4346")
		step.get_node(^"Row/Marker").add_theme_stylebox_override("panel", frame)
		step.get_node(^"Row/Marker/Number").visible = number >= index
		step.get_node(^"Row/Marker/Done").visible = number < index
		step.get_node(^"Rule").color = NEUTRAL if number == index else MUTED if number < index else Color("3e4346")
		step.get_node(^"Rule").visible = is_compact() or number == index
		step.get_node(^"Connector").visible = false
	get_node(^"Layout/Footer/Row/Back").disabled = index == 0
	if not _steps.is_empty():
		get_node(^"Layout/Header/Row/CurrentStep").text = "%02d / %02d · %s" % [index + 1, _steps.size(), _steps[index].get_node(^"Row/Name").text]

func set_primary(text: String, disabled: bool, icon: Texture2D = null) -> void:
	var button := get_node(^"Layout/Footer/Row/Primary") as Button
	button.text = text
	button.accessibility_name = text
	button.tooltip_text = ""
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
	get_node(^"Layout/Steps").custom_minimum_size.y = 4 if phone else 44 if tablet else 52
	get_node(^"Layout/Footer").custom_minimum_size.y = 52 if phone else 60 if tablet else 68
	for path in [^"Layout/Header", ^"Layout/Steps", ^"Layout/Footer"]:
		get_node(path).add_theme_constant_override("margin_left", 0)
		get_node(path).add_theme_constant_override("margin_right", 20)
	get_node(^"Layout/Body").add_theme_constant_override("separation", 16 if phone else 20 if tablet else 28)
	get_context_slot().custom_minimum_size.x = 208 if phone else 246 if tablet else 336
	for edge in ["left", "right", "top", "bottom"]:
		get_context_slot().add_theme_constant_override("margin_" + edge, 12 if edge == "right" else 4)
		get_stage_slot().add_theme_constant_override("margin_" + edge, 4)
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
		step.get_node(^"Row/Name").add_theme_font_size_override("font_size", 17 if tablet else 20)
		step.get_node(^"Row").offset_top = 8
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

func _fit_surfaces() -> void:
	if not is_node_ready(): return
	var layout: Control = get_node(^"Layout")
	var header: Control = get_node(^"Layout/Header")
	var steps: Control = get_node(^"Layout/Steps")
	var body: Control = get_node(^"Layout/Body")
	var footer: Control = get_node(^"Layout/Footer")
	var h := Rect2(layout.position + header.position - Vector2(12, 6), header.size + Vector2(20, 12))
	var b := Rect2(layout.position + steps.position - Vector2(12, 4), Vector2(body.size.x + 24, body.position.y + body.size.y - steps.position.y + 8))
	var f := Rect2(layout.position + footer.position - Vector2(12, 4), footer.size + Vector2(24, 12))
	get_node(^"Frame").set_sections(h, b, f)
	queue_redraw()

func _draw() -> void:
	if not is_node_ready(): return
	var context := get_context_slot()
	var start := context.global_position - global_position + Vector2(context.size.x, 4)
	draw_line(start, start + Vector2(0, context.size.y - 8), Color("bc927747"))

func _reveal_stage() -> void:
	if is_inside_tree(): get_node(^"Frame").reveal(get_stage_slot())

func _label_line_height(label: Control, multiplier: float) -> void:
	preload("res://rookframe/ui/theme/silkbound_line_height.gd").apply(label, multiplier)
