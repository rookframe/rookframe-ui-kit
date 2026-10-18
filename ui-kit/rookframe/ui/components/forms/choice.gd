@tool
extends Button
## One native selection target. ButtonGroup owns exclusive-selection rules.
signal selection_changed(selected: bool)
enum Variant { ROW, CARD, MARKED_ROW, MARKED_CARD, LIST }
const Appearance = preload("res://rookframe/ui/_internal/presentation/appearance.gd")
@export var title: String = "Choice":
	set(value):
		if title == value: return
		title = value
		_refresh()
@export_multiline var description: String = "":
	set(value):
		if description == value: return
		description = value
		_refresh()
@export var action_label: String = "Select":
	set(value):
		if action_label == value: return
		action_label = value
		_refresh()
@export var selected_label: String = "Selected":
	set(value):
		if selected_label == value: return
		selected_label = value
		_refresh()
@export var marker_text: String = "":
	set(value):
		if marker_text == value: return
		marker_text = value
		_refresh()
@export var value_text: String = "":
	set(value):
		if value_text == value: return
		value_text = value
		_refresh()
@export var leading_icon: Texture2D = null:
	set(value):
		if leading_icon == value: return
		leading_icon = value
		_refresh()
@export var show_description: bool = true:
	set(value):
		if show_description == value: return
		show_description = value
		_refresh()
@export var compact: bool = false:
	set(value):
		if compact == value: return
		compact = value
		_refresh()
@export var variant: Variant = Variant.ROW:
	set(value):
		if variant == value: return
		variant = value
		_refresh()
var _configuring := false
var _refresh_pending := false
var _styled_variant := -1
var _styled_theme: Theme
var _automatic_name := ""
var _automatic_description := ""

func _ready() -> void:
	$Content.minimum_size_changed.connect(_fit_content)
	toggled.connect(func(selected: bool):
		_update_state()
		selection_changed.emit(selected)
	)
	_refresh()

func set_selected(selected: bool) -> void:
	button_pressed = selected
	_update_state()

func is_selected() -> bool:
	return button_pressed

func set_compact(enabled: bool) -> void:
	compact = enabled

func _notification(what: int) -> void:
	if what in [NOTIFICATION_THEME_CHANGED, NOTIFICATION_TRANSLATION_CHANGED] and is_node_ready() and not _configuring and not _refresh_pending:
		_refresh_pending = true
		_refresh.call_deferred()
	if what == NOTIFICATION_DRAW and is_node_ready():
		_update_state()

func _presentation_changed() -> void:
	_styled_variant = -1
	_refresh()

func _refresh() -> void:
	if not is_node_ready() or _configuring:
		return
	_configuring = true
	_refresh_pending = false
	var owning_theme := Appearance.owning_theme(self)
	if _styled_variant != variant or _styled_theme != owning_theme:
		Appearance.restore(self)
		for role in ["title", "description"]:
			var label := _label(role)
			for item in ["font_color", "font_shadow_color"]:
				label.remove_theme_color_override(item)
			label.remove_theme_font_override("font")
			label.remove_theme_font_size_override("font_size")
			label.remove_theme_constant_override("shadow_offset_y")
		theme_type_variation = ["RookframeChoiceRow", "components_switch", "", "", "TaskChoice"][variant]
		if Appearance.has_hook(self, &"_style_choice"):
			Appearance.invoke(self, &"_style_choice")
		_styled_variant = variant
		_styled_theme = owning_theme
	$Content/Row/Copy/Title.text = title
	$Content/Row/Copy/Description.text = description
	$Content/Row/Copy/Description.visible = show_description and not description.is_empty()
	$Content/Row/Icon.texture = leading_icon
	$Content/Row/Icon.visible = leading_icon != null
	$Content/Row/Value.text = value_text
	$Content/Row/Value.visible = not value_text.is_empty()
	$Content/Row/State.visible = variant in [Variant.ROW, Variant.MARKED_ROW, Variant.MARKED_CARD]
	$Content/Row/SelectionMark.visible = variant == Variant.CARD
	$Content/Row/Marker/Glyph.text = marker_text
	if variant == Variant.CARD:
		theme_type_variation = "components_switch__compact" if compact else "components_switch"
		_style_card()
	else:
		var padding := Vector2(16, 12)
		if variant == Variant.MARKED_ROW: padding = Vector2(12, 8)
		if variant == Variant.MARKED_CARD: padding = Vector2(18, 16)
		if variant == Variant.LIST: padding = Vector2(16, 9)
		if compact: padding.y = 8
		for side in ["left", "right", "top", "bottom"]:
			$Content.add_theme_constant_override("margin_" + side, int(padding.x if side in ["left", "right"] else padding.y))
		$Content/Row/Copy.custom_minimum_size.x = 0
		$Content/Row.add_theme_constant_override("separation", 10 if variant == Variant.MARKED_ROW else 16)
		$Content/Row/Copy.add_theme_constant_override("separation", 4)
	_update_state()
	_fit_content()
	_configuring = false

func _fit_content() -> void:
	var minimum := 72
	if variant == Variant.CARD: minimum = get_theme_constant("minimum_height") if has_theme_constant("minimum_height") else (88 if compact else 116)
	elif variant == Variant.MARKED_CARD: minimum = 124
	elif variant == Variant.LIST: minimum = 44
	elif compact: minimum = 44
	custom_minimum_size = $Content.get_combined_minimum_size().max(Vector2(44, minimum))

func _update_state() -> void:
	if not is_node_ready(): return
	$Content/Row/State.text = selected_label if button_pressed else action_label
	$Content/Row/State.theme_type_variation = &"RookframeSuccess" if button_pressed else &"RookframeStatus"
	var marked: bool = variant in [Variant.MARKED_ROW, Variant.MARKED_CARD]
	$Content/Row/Marker.visible = marked and not button_pressed
	$Content/Row/SelectedMarker.visible = marked and button_pressed
	if accessibility_name.is_empty() or accessibility_name == _automatic_name:
		accessibility_name = tr(title)
		_automatic_name = accessibility_name
	if accessibility_description.is_empty() or accessibility_description == _automatic_description:
		accessibility_description = tr(description) + (". " + tr(value_text) if not value_text.is_empty() else "")
		_automatic_description = accessibility_description
	if variant == Variant.CARD:
		_update_card_state()

func _label(role: String) -> Label:
	return $Content/Row/Copy/Title if role == "title" else $Content/Row/Copy/Description

func _style_card() -> void:
	for side in ["left", "right", "top", "bottom"]:
		var padding := "padding_x" if side in ["left", "right"] else "padding_y"
		var margin := get_theme_constant(padding) if has_theme_constant(padding) else int(get_theme_stylebox("normal").get_content_margin({"left": SIDE_LEFT, "right": SIDE_RIGHT, "top": SIDE_TOP, "bottom": SIDE_BOTTOM}[side]))
		$Content.add_theme_constant_override("margin_" + side, margin)
	$Content/Row.add_theme_constant_override("separation", get_theme_constant("selection_gap") if has_theme_constant("selection_gap") else get_theme_constant("separation", "HBoxContainer"))
	$Content/Row/Copy.add_theme_constant_override("separation", get_theme_constant("copy_gap") if has_theme_constant("copy_gap") else get_theme_constant("separation", "VBoxContainer"))
	$Content/Row/Copy.custom_minimum_size.x = get_theme_constant("copy_minimum_width")
	for role in ["title", "description"]:
		var label := _label(role)
		label.add_theme_font_override("font", get_theme_font(role + "_font") if has_theme_font(role + "_font") else get_theme_font("font", "Button"))
		label.add_theme_font_size_override("font_size", get_theme_font_size(role + "_size") if has_theme_font_size(role + "_size") else get_theme_font_size("font_size", "Button"))
		if has_theme_color("ink_shadow"):
			label.add_theme_color_override("font_shadow_color", get_theme_color("ink_shadow"))
			label.add_theme_constant_override("shadow_offset_y", get_theme_constant("ink_shadow_size"))
		else:
			label.remove_theme_color_override("font_shadow_color")
			label.remove_theme_constant_override("shadow_offset_y")
	# Keep the icon's space when unchecked so selection never shifts the copy.
	var mark := get_theme_icon("selection_mark") if has_theme_icon("selection_mark") else get_theme_icon("checked", "CheckBox")
	$Content/Row/SelectionMark.texture = mark
	$Content/Row/SelectionMark.custom_minimum_size = mark.get_size()


func _update_card_state() -> void:
	var state: String = {DRAW_NORMAL: "normal", DRAW_HOVER: "hover", DRAW_PRESSED: "pressed", DRAW_HOVER_PRESSED: "hover_pressed", DRAW_DISABLED: "disabled"}[get_draw_mode()]
	mouse_default_cursor_shape = CURSOR_ARROW if disabled else CURSOR_POINTING_HAND
	var disabled_mark := get_theme_color("selection_disabled") if has_theme_color("selection_disabled") else get_theme_color("font_disabled_color", "Button")
	$Content/Row/SelectionMark.self_modulate = Color.TRANSPARENT if not button_pressed else disabled_mark if disabled else Color.WHITE
	for role in ["title", "description"]:
		var slot := "disabled" if disabled else "selected" if button_pressed else state
		var native_slot: String = {"normal": "font_color", "hover": "font_hover_color", "pressed": "font_pressed_color", "hover_pressed": "font_hover_pressed_color", "disabled": "font_disabled_color", "selected": "font_pressed_color"}[slot]
		var color := get_theme_color(role + "_" + slot) if has_theme_color(role + "_" + slot) else get_theme_color(native_slot, "Button")
		var label := _label(role)
		if label.get_theme_color("font_color") != color:
			label.add_theme_color_override("font_color", color)


func _enter_tree() -> void:
	preload("res://rookframe/ui/_internal/presentation/binding.gd").attach(self)
