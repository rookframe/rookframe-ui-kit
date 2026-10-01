@tool
extends Control
## Fixed task frame. The consumer supplies the steps, context and stage content.
signal back_requested
signal restart_requested
signal primary_requested
signal close_requested

const STEP = preload("res://rookframe/ui/_internal/surfaces/wizard_step.tscn")
var _steps: Array[Control] = []
var _index := 0

func _ready() -> void:
	get_node(^"Layout/Footer/Row/Back").pressed.connect(func(): back_requested.emit())
	get_node(^"Layout/Footer/Row/Restart").pressed.connect(func(): restart_requested.emit())
	get_node(^"Layout/Footer/Row/Primary").pressed.connect(func(): primary_requested.emit())
	get_node(^"Layout/Header/Row/Close").pressed.connect(func(): close_requested.emit())
	resized.connect(_fit)
	_fit()

func configure(brand: String, title: String, steps: Array[String], labels: Dictionary = {}) -> void:
	get_node(^"Layout/Header/Row/Brand/Name").text = brand
	get_node(^"Layout/Header/Title").text = title
	get_node(^"Layout/Header/Row/Brand/Subtitle").text = str(labels.get("subtitle", "Character creation"))
	get_node(^"Layout/Footer/Row/Back").text = str(labels.get("back", "Back"))
	get_node(^"Layout/Footer/Row/Restart").text = str(labels.get("restart", "Start over"))
	get_node(^"Layout/Footer/Row/Hint").text = str(labels.get("hint", "Results stay with you when you go back."))
	get_node(^"Layout/Header/Row/Close").accessibility_name = str(labels.get("close", "Close character creation"))
	for child in _steps:
		child.get_parent().remove_child(child)
		child.queue_free()
	_steps.clear()
	for index in steps.size():
		var step := STEP.instantiate() as Control
		step.get_node(^"Row/Marker/Number").text = "%02d" % (index + 1)
		step.get_node(^"Row/Name").text = steps[index]
		get_node(^"Layout/Steps/Row").add_child(step)
		_steps.append(step)
	set_step(_index)
	_fit()

func set_step(index: int) -> void:
	_index = index
	for number in _steps.size():
		var color := Color("f0bb32") if number == index else Color("d9d4d1") if number < index else Color("91999a")
		_steps[number].get_node(^"Row/Name").add_theme_color_override("font_color", color)
		_steps[number].get_node(^"Row/Marker/Number").add_theme_color_override("font_color", color)
		_steps[number].get_node(^"Row/Marker/Done").self_modulate = Color("44e9e9")
		var frame := _steps[number].get_node(^"Row/Marker").get_theme_stylebox("panel").duplicate() as StyleBoxFlat
		frame.border_color = Color("f0bb32") if number == index else Color("223237")
		_steps[number].get_node(^"Row/Marker").add_theme_stylebox_override("panel", frame)
		_steps[number].get_node(^"Row/Marker/Number").visible = number >= index
		_steps[number].get_node(^"Row/Marker/Done").visible = number < index
		_steps[number].get_node(^"Rule").color = Color("f0bb32") if number == index else Color("44e9e9") if number < index else Color("223237")
		_steps[number].get_node(^"Rule").visible = size.y <= 560 or number == index
	get_node(^"Layout/Footer/Row/Back").disabled = index == 0
	if not _steps.is_empty():
		get_node(^"Layout/Header/Row/CurrentStep").text = "%02d / %02d · %s" % [index + 1, _steps.size(), _steps[index].get_node(^"Row/Name").text]

func set_primary(text: String, disabled: bool, icon: Texture2D = null) -> void:
	get_node(^"Layout/Footer/Row/Primary").text = text
	get_node(^"Layout/Footer/Row/Primary").disabled = disabled
	get_node(^"Layout/Footer/Row/Primary/Center/Content/Label").text = text
	get_node(^"Layout/Footer/Row/Primary").modulate.a = 0.48 if disabled else 1.0
	get_node(^"Layout/Footer/Row/Primary/Center/Content/Icon").texture = icon
	get_node(^"Layout/Footer/Row/Primary/Center/Content/Icon").visible = icon != null

func set_back_enabled(enabled: bool) -> void:
	get_node(^"Layout/Footer/Row/Back").disabled = not enabled

func get_context_slot() -> MarginContainer:
	return get_node(^"Layout/Body/ContextSlot")

func get_stage_slot() -> MarginContainer:
	return get_node(^"Layout/Body/StageSlot")

func _fit() -> void:
	if not is_node_ready():
		return
	var phone := size.y <= 560
	var tablet := size.x <= 1150 and not phone
	var inset := 14 if phone else 20 if tablet else 32
	get_node(^"Layout/Header").custom_minimum_size.y = 48 if phone else 64 if tablet else 76
	get_node(^"Layout/Steps").custom_minimum_size.y = 4 if phone else 60 if tablet else 72
	get_node(^"Layout/Footer").custom_minimum_size.y = 54 if phone else 66 if tablet else 80
	for path in [^"Layout/Header", ^"Layout/Steps", ^"Layout/Footer"]:
		get_node(path).add_theme_constant_override("margin_left", 0 if phone and path == ^"Layout/Steps" else inset)
		get_node(path).add_theme_constant_override("margin_right", 0 if phone and path == ^"Layout/Steps" else inset)
	get_context_slot().custom_minimum_size.x = 210 if phone else 254 if tablet else 400 if size.x >= 1500 else 360
	var context_inset := 12 if phone else 16 if tablet else 32
	for edge in ["left", "right", "top", "bottom"]:
		get_context_slot().add_theme_constant_override("margin_" + edge, 20 if tablet and edge in ["top", "bottom"] else context_inset)
		get_stage_slot().add_theme_constant_override("margin_" + edge, (16 if edge in ["left", "right"] else 8) if phone else 22 if tablet else (42 if edge in ["left", "right"] else 36))
	get_node(^"Layout/Header/Title").visible = not phone
	get_node(^"Layout/Header/Title").add_theme_font_size_override("font_size", 24 if tablet else 30)
	get_node(^"Layout/Header/Row/CurrentStep").visible = phone
	get_node(^"Layout/Header/Row/Icon").custom_minimum_size = Vector2(24, 24) if phone else Vector2(34, 34)
	get_node(^"Layout/Header/Row/Brand/Name").add_theme_font_size_override("font_size", 16 if phone else 22)
	get_node(^"Layout/Header/Row").add_theme_constant_override("separation", 10 if phone else 16)
	get_node(^"Layout/Header/Row/Close").custom_minimum_size = Vector2(44, 44) if phone else Vector2(48, 48)
	get_node(^"Layout/Steps/Row").add_theme_constant_override("separation", 3 if phone else 8)
	get_node(^"Layout/Footer/Row").add_theme_constant_override("separation", 4 if phone else 16)
	get_node(^"Layout/Footer/Row/Primary").custom_minimum_size = Vector2(175, 44) if phone else Vector2(204, 46)
	for action in ["Back", "Restart", "Primary"]:
		get_node("Layout/Footer/Row/" + action).add_theme_font_size_override("font_size", 11 if phone and action == "Restart" else 12 if phone else 15)
	get_node(^"Layout/Footer/Row/Primary/Center/Content/Label").add_theme_font_size_override("font_size", 12 if phone else 15)
	get_node(^"Layout/Footer/Row/Primary/Center/Content/Icon").custom_minimum_size = Vector2(20, 20) if phone else Vector2(22, 22)
	get_node(^"Layout/Header/Row/Brand/Subtitle").visible = not phone
	get_node(^"Layout/Footer/Row/Hint").visible = not phone and not tablet
	var header: float = get_node(^"Layout/Header").custom_minimum_size.y
	var progress: float = get_node(^"Layout/Steps").custom_minimum_size.y
	var footer: float = get_node(^"Layout/Footer").custom_minimum_size.y
	var context: float = get_context_slot().custom_minimum_size.x
	_set_surface(^"CanvasSurface", Rect2(Vector2.ONE, size - Vector2(2, 2)))
	_set_surface(^"HeaderSurface", Rect2(1, 1, size.x - 2, header))
	_set_surface(^"ContextSurface", Rect2(1, 1 + header + progress, context, size.y - header - progress - footer - 2))
	_set_surface(^"FooterSurface", Rect2(1, size.y - footer - 1, size.x - 2, footer))
	_set_surface(^"HeaderRuleSurface", Rect2(1, header, size.x - 2, 1))
	_set_surface(^"StepsRuleSurface", Rect2(1, header + progress, size.x - 2, 1))
	_set_surface(^"ContextRuleSurface", Rect2(context, header + progress, 1, size.y - header - progress - footer - 1))
	_set_surface(^"FooterRuleSurface", Rect2(1, size.y - footer - 1, size.x - 2, 1))
	for step in _steps:
		step.get_node(^"Row").visible = not phone
		step.get_node(^"Row/Name").add_theme_font_size_override("font_size", 13 if tablet else 16)
	set_step(_index)

func _set_surface(path: NodePath, rect: Rect2) -> void:
	var surface := get_node(path) as Control
	surface.position = rect.position
	surface.size = rect.size
