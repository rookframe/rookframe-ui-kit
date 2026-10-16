@tool
extends Control
## Full-screen task frame. Consumers own the draft and task content.
signal back_requested
signal restart_requested
signal primary_requested
signal close_requested

@export var reduced_motion := false:
	set(value):
		reduced_motion = value
		if is_node_ready(): get_node(^"Frame").reduced_motion = value

const STEP = preload("res://rookframe/ui/_internal/surfaces/wizard_step.tscn")
@export var step_scene: PackedScene = STEP
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
		var step := step_scene.instantiate() as Control
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
		reveal_stage.call_deferred()
	for number in _steps.size():
		var step := _steps[number]
		_style_step(step, number, index)
		step.get_node(^"Row/Marker/Number").visible = number >= index
		step.get_node(^"Row/Marker/Done").visible = number < index
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
	_style_primary_state(button)
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
	get_node(^"Ledger").hide()
	get_node(^"StageSurface").hide()
	get_context_slot().custom_minimum_size.x = size.x * 0.3
	set_step(_index)
	_fit_surfaces.call_deferred()

func _fit_primary() -> void:
	pass

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
	pass

func reveal_stage() -> void:
	if is_inside_tree(): get_node(^"Frame").reveal(get_stage_slot())

func _label_line_height(label: Control, multiplier: float) -> void:
	pass


func _style_step(step: Control, number: int, index: int) -> void:
	pass

func _style_primary_state(button: Button) -> void:
	pass
