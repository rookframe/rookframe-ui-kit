@tool
extends Window

## Designed modal composition with native Window focus, modality, and input.

signal confirmed
signal cancelled

enum Tone {
	INFORMATION,
	CONFIRMATION,
	DANGER,
	SUCCESS,
}

const DIALOG_WIDTH := 720
const MINIMUM_DIALOG_HEIGHT := 300
const INFORMATION_ICON := preload("res://rookframe/ui/icons/info.svg")
const CONFIRMATION_ICON := preload("res://rookframe/ui/icons/warning.svg")
const DANGER_ICON := preload("res://rookframe/ui/icons/error.svg")
const SUCCESS_ICON := preload("res://rookframe/ui/icons/check.svg")
const SCRIM_COLOR := Color(0.0, 0.025, 0.032, 0.82)

var _fit_pending := false
var _scrim: ColorRect

@export var tone: Tone = Tone.INFORMATION:
	set(value):
		tone = value
		_refresh()

@export var eyebrow := "ROOKFRAME":
	set(value):
		eyebrow = value
		_refresh()

@export var heading := "Dialog title":
	set(value):
		heading = value
		_refresh()

@export_multiline var description := "Explain the decision and its consequence.":
	set(value):
		description = value
		_refresh()

@export var confirm_label := "Continue":
	set(value):
		confirm_label = value
		_refresh()

@export var cancel_label := "Cancel":
	set(value):
		cancel_label = value
		_refresh()

@export var show_cancel := true:
	set(value):
		show_cancel = value
		_refresh()


func _ready() -> void:
	var cancel_button := get_node(^"Shell/Content/Actions/Cancel") as Button
	var confirm_button := get_node(^"Shell/Content/Actions/Confirm") as Button
	if not close_requested.is_connected(_cancel):
		close_requested.connect(_cancel)
	if not visibility_changed.is_connected(_sync_scrim):
		visibility_changed.connect(_sync_scrim)
	if not cancel_button.pressed.is_connected(_cancel):
		cancel_button.pressed.connect(_cancel)
	if not confirm_button.pressed.is_connected(_confirm):
		confirm_button.pressed.connect(_confirm)
	var body_slot := get_body_slot()
	if not body_slot.child_order_changed.is_connected(_refresh_body_visibility):
		body_slot.child_order_changed.connect(_refresh_body_visibility)
	_refresh()


func _unhandled_key_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed(&"ui_cancel"):
		_cancel()
		get_viewport().set_input_as_handled()


func get_body_slot() -> Container:
	return get_node(^"Shell/Content/Body/BodySlot") as Container


func open_dialog() -> void:
	_refresh()
	_ensure_scrim()
	var initial_height := 480 if get_body_slot().get_child_count() > 0 else 320
	popup_centered(Vector2i(DIALOG_WIDTH, initial_height))
	if not _fit_pending:
		_fit_pending = true
		_fit_open_dialog()


func close_dialog() -> void:
	hide()
	_remove_scrim()


func _focus_initial() -> void:
	var target := get_node(^"Shell/Content/Actions/Confirm") as Button
	target.grab_focus()


func _fit_open_dialog() -> void:
	for _pass_index in range(2):
		await get_tree().process_frame
		if not visible:
			_fit_pending = false
			return
		var shell := get_node(^"Shell") as PanelContainer
		var content_height := ceili(shell.get_combined_minimum_size().y / 4.0) * 4
		var target_height := maxi(MINIMUM_DIALOG_HEIGHT, content_height)
		if get_body_slot().get_child_count() > 0:
			target_height = maxi(480, target_height)
		target_height = mini(target_height, 680)
		if size.y != target_height or size.x != DIALOG_WIDTH:
			var previous_center := position + size / 2
			size = Vector2i(DIALOG_WIDTH, target_height)
			position = previous_center - size / 2
	_fit_pending = false
	call_deferred(&"_focus_initial")


func _confirm() -> void:
	hide()
	_remove_scrim()
	confirmed.emit()


func _cancel() -> void:
	hide()
	_remove_scrim()
	cancelled.emit()


func _exit_tree() -> void:
	_remove_scrim()


func _sync_scrim() -> void:
	if visible:
		_ensure_scrim()
	else:
		_remove_scrim()


func _ensure_scrim() -> void:
	if is_instance_valid(_scrim):
		return
	var host := get_parent() as Control
	if host == null:
		return
	var dialog_index := get_index()
	_scrim = ColorRect.new()
	_scrim.name = "DialogScrim"
	_scrim.color = SCRIM_COLOR
	_scrim.mouse_filter = Control.MOUSE_FILTER_STOP
	_scrim.focus_mode = Control.FOCUS_NONE
	_scrim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_scrim.z_index = 100
	host.add_child(_scrim)
	host.move_child(_scrim, dialog_index)


func _remove_scrim() -> void:
	if not is_instance_valid(_scrim):
		_scrim = null
		return
	_scrim.queue_free()
	_scrim = null


func _refresh_body_visibility() -> void:
	if not is_inside_tree():
		return
	var body := get_node(^"Shell/Content/Body") as PanelContainer
	body.visible = get_body_slot().get_child_count() > 0


func _refresh() -> void:
	if not is_inside_tree():
		return
	var top_rule := get_node_or_null(^"Shell/Content/TopRule") as ColorRect
	var tone_icon := get_node_or_null(^"Shell/Content/Header/ToneFrame/ToneIcon") as TextureRect
	var eyebrow_label := get_node_or_null(^"Shell/Content/Header/Copy/Eyebrow") as Label
	var title_label := get_node_or_null(^"Shell/Content/Header/Copy/Title") as Label
	var message := get_node_or_null(^"Shell/Content/Message") as PanelContainer
	var description_label := get_node_or_null(^"Shell/Content/Message/Description") as Label
	var shortcut_hint := get_node_or_null(^"Shell/Content/Actions/ShortcutHint") as Label
	var cancel_button := get_node_or_null(^"Shell/Content/Actions/Cancel") as Button
	var confirm_button := get_node_or_null(^"Shell/Content/Actions/Confirm") as Button
	var semantic_color := _tone_color()
	if top_rule != null:
		top_rule.color = semantic_color
	if tone_icon != null:
		tone_icon.texture = _tone_icon()
		tone_icon.modulate = semantic_color
	if eyebrow_label != null:
		eyebrow_label.text = eyebrow
		eyebrow_label.theme_type_variation = _tone_text_variation()
	if title_label != null:
		title_label.text = heading
	if description_label != null:
		description_label.text = description
	if message != null:
		message.visible = not description.is_empty()
	if shortcut_hint != null:
		shortcut_hint.text = "ESC · CANCEL    ENTER · CONFIRM" if show_cancel else "ENTER · CONTINUE"
	if cancel_button != null:
		cancel_button.text = cancel_label
		cancel_button.visible = show_cancel
		cancel_button.accessibility_name = cancel_label
	if confirm_button != null:
		confirm_button.text = confirm_label
		confirm_button.accessibility_name = confirm_label
	_refresh_body_visibility()
	title = heading
	accessibility_name = heading
	accessibility_description = description


func _tone_icon() -> Texture2D:
	match tone:
		Tone.CONFIRMATION:
			return CONFIRMATION_ICON
		Tone.DANGER:
			return DANGER_ICON
		Tone.SUCCESS:
			return SUCCESS_ICON
		_:
			return INFORMATION_ICON


func _tone_color() -> Color:
	match tone:
		Tone.DANGER:
			return RookframeUiTokens.COLOR_DANGER
		Tone.SUCCESS:
			return RookframeUiTokens.COLOR_SUCCESS
		_:
			return RookframeUiTokens.COLOR_HIERARCHY


func _tone_text_variation() -> StringName:
	match tone:
		Tone.DANGER:
			return &"RookframeError"
		Tone.SUCCESS:
			return &"RookframeSuccess"
		_:
			return &"RookframeLabel"
