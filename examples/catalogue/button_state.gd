extends TextureRect
## Catalogue-only preview. Each viewport retains a real native Button state.
enum State { NORMAL, HOVERED, PRESSED, DISABLED, FOCUSED }
@export var state := State.NORMAL
@export var primary := false
var _mouse_entered := false
@onready var button: Button = $Viewport/Button


func _ready() -> void:
	button.usage = &"menu.button.primary" if primary else &"menu.button.standard"
	button.text = ["Normal", "Hovered", "Pressed", "Disabled", "Focused"][state]
	resized.connect(_resize_viewport)
	button.resized.connect(_apply_state, CONNECT_DEFERRED)
	_resize_viewport()
	_apply_state.call_deferred()


func configure(active_theme: Theme, compact: bool) -> void:
	button.theme = active_theme
	button.set_compact(compact)
	var height := 44 if compact else 64 if primary else 60
	custom_minimum_size.y = height + 36
	button.custom_minimum_size.y = height
	_apply_state.call_deferred()


func _apply_state() -> void:
	button.release_focus()
	button.disabled = state == State.DISABLED
	button.toggle_mode = state == State.PRESSED
	button.set_pressed_no_signal(state == State.PRESSED)
	if state == State.FOCUSED:
		button.grab_focus()
	elif state == State.HOVERED:
		if not _mouse_entered:
			$Viewport.notify_mouse_entered()
			_mouse_entered = true
		var motion := InputEventMouseMotion.new()
		motion.position = button.get_rect().get_center()
		$Viewport.push_input(motion, true)


func _resize_viewport() -> void:
	$Viewport.size = Vector2i(size.max(Vector2.ONE))
