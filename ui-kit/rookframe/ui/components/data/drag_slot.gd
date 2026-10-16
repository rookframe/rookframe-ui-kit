extends Button
## Pointer, controller, keyboard and touch share the context request path.
const Payload = preload("res://rookframe/ui/_internal/interaction/payload.gd")
@export var slot_id := "":
	set(value):
		if is_inside_tree() and value != slot_id:
			push_error("DragSlot: set slot_id before entering the tree")
			return
		slot_id = value
@export var context: RookframeTransferContext:
	set(value):
		if is_inside_tree() and value != context:
			push_error("DragSlot: set context before entering the tree")
			return
		context = value
@export var can_source := true
@export var can_target := true
@export var payload: Dictionary = {}:
	set(value):
		if not Payload.valid(value):
			push_error("DragSlot: payload must be acyclic plain data")
			return
		payload = value.duplicate(true)
var _registered := false
var _pointer_drag := false
var _suppress_release := false

func _ready() -> void:
	toggle_mode = false
	pressed.connect(_activate)
	focus_entered.connect(_target_feedback)
	mouse_entered.connect(_target_feedback)

func _enter_tree() -> void:
	if is_instance_valid(context): _registered = context._register(self)

func get_content_slot() -> Container:
	return %ContentSlot

func _activate() -> void:
	if disabled or not _registered or not is_instance_valid(context) or _pointer_drag or _suppress_release: return
	if context.get_state() == &"idle": context.begin_transfer(slot_id)
	elif context.get_state() == &"carrying": context.request_placement(slot_id)

func _get_drag_data(_at_position: Vector2) -> Variant:
	if disabled or not _registered or not is_instance_valid(context) or not context.begin_transfer(slot_id): return null
	_pointer_drag = true
	_suppress_release = true
	var preview := Label.new()
	preview.text = accessibility_name if not accessibility_name.is_empty() else text
	set_drag_preview(preview)
	return {"context": context.get_instance_id(), "source": slot_id}

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	if disabled or not _registered or not is_instance_valid(context) or not data is Dictionary: return false
	if data.get("context") != context.get_instance_id(): return false
	_target_feedback()
	return context.evaluate_target(slot_id).allowed

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	if _can_drop_data(_at_position, data): context.request_placement(slot_id)

func _notification(what: int) -> void:
	if what == NOTIFICATION_DRAG_END and _pointer_drag:
		_pointer_drag = false
		if is_instance_valid(context) and context.get_state() == &"carrying": context.cancel_transfer(&"invalid_drop")
		_release_drag.call_deferred()

func _release_drag() -> void:
	_suppress_release = false

func _target_feedback() -> void:
	if _registered and is_instance_valid(context): context._target_feedback(slot_id)

func _process(_delta: float) -> void:
	focus_mode = Control.FOCUS_ALL if _registered and not disabled else Control.FOCUS_NONE

func _exit_tree() -> void:
	if _registered and is_instance_valid(context): context._unregister(self)
	_registered = false
	_pointer_drag = false
