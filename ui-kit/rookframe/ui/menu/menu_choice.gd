@tool
extends OptionButton
## Native OptionButton/PopupMenu own selection, accessibility, search and input.
## This recipe binds density, the inset tray, and its trailing selection marker.
const TrailingCheck = preload("../_internal/menu/trailing_check.gd")
@export var compact := false:
	set(value):
		compact = value
		if is_node_ready():
			_refresh_theme()
var _refresh_pending := false
var _configuring := false
var _popup_items: Control


func _ready() -> void:
	get_popup().about_to_popup.connect(_prepare_popup)
	get_popup().visibility_changed.connect(_popup_visibility_changed)
	get_popup().window_input.connect(_update_popup_cursor)
	_bind_popup_cursors(get_popup())
	_refresh_theme()


func _bind_popup_cursors(node: Node) -> void:
	# PopupMenu is a Window; its item canvas and scrollbars own the cursor.
	# Discover native controls by type instead of relying on internal node paths.
	for child in node.get_children(true):
		if child is ScrollBar:
			child.mouse_default_cursor_shape = CURSOR_POINTING_HAND
		elif child is Control and node is ScrollContainer and child.focus_mode == FOCUS_ALL:
			_popup_items = child
		_bind_popup_cursors(child)


func _update_popup_cursor(event: InputEvent) -> void:
	if not event is InputEventMouse or not is_instance_valid(_popup_items):
		return
	# Native popup hit testing precedes item input in embedded and separate windows.
	var menu := get_popup()
	var index := menu.get_focused_item()
	var selectable := index >= 0 and not menu.is_item_disabled(index) and not menu.is_item_separator(index)
	_popup_items.mouse_default_cursor_shape = CURSOR_POINTING_HAND if selectable else CURSOR_ARROW


func set_compact(enabled: bool) -> void:
	compact = enabled


func _notification(what: int) -> void:
	if what == NOTIFICATION_THEME_CHANGED and is_node_ready() and not _configuring:
		if not _refresh_pending:
			_refresh_pending = true
			_refresh_theme.call_deferred()
	if what == NOTIFICATION_VISIBILITY_CHANGED and is_node_ready() and not is_visible_in_tree():
		get_popup().hide()


func _refresh_theme() -> void:
	_configuring = true
	_refresh_pending = false
	theme_type_variation = &"settings_choice__compact" if compact else &"settings_choice"
	var menu := get_popup()
	if menu.visible:
		menu.hide()
	# A local Theme holds instance-bound textures, never modifying the shared Theme.
	menu.theme = null
	menu.theme_type_variation = &"settings_popup__compact" if compact else &"settings_popup"
	custom_minimum_size.y = maxi(44, get_theme_constant("minimum_height"))
	# Keep native popup checks and scrollbars when no optional marker is supplied.
	if not has_theme_icon("selection_mark"):
		_configuring = false
		return
	var local_theme := Theme.new()
	var check := TrailingCheck.new()
	check.popup = weakref(menu)
	check.image = get_theme_icon("selection_mark")
	check.trailing_inset = get_theme_constant("selection_inset")
	var disabled_check := TrailingCheck.new()
	disabled_check.popup = weakref(menu)
	disabled_check.image = check.image
	disabled_check.trailing_inset = check.trailing_inset
	disabled_check.disabled_tint = get_theme_color("selection_disabled")
	for slot in ["checked", "radio_checked"]:
		local_theme.set_icon(slot, menu.theme_type_variation, check)
		local_theme.set_icon(slot + "_disabled", menu.theme_type_variation, disabled_check)
	for slot in ["unchecked", "radio_unchecked", "unchecked_disabled", "radio_unchecked_disabled"]:
		local_theme.set_icon(slot, menu.theme_type_variation, get_theme_icon("empty_mark"))
	# PopupMenu creates its own native scrollbar; style its base type locally.
	for slot in ["scroll", "grabber", "grabber_highlight", "grabber_pressed"]:
		local_theme.set_stylebox(slot, &"VScrollBar", get_theme_stylebox(slot, &"settings_scrollbar"))
	for slot in ["increment", "decrement", "increment_highlight", "decrement_highlight", "increment_pressed", "decrement_pressed"]:
		local_theme.set_icon(slot, &"VScrollBar", get_theme_icon("empty_mark"))
	menu.theme = local_theme
	_configuring = false


func _prepare_popup() -> void:
	# PopupMenu has completed native sizing after about_to_popup returns.
	_place_popup.call_deferred()


func _place_popup() -> void:
	var menu := get_popup()
	if not menu.visible:
		return
	var screen_transform := get_screen_transform()
	var bounds := Rect2(screen_transform.origin, size * screen_transform.get_scale())
	var factor := bounds.size.x / size.x
	var inset := get_theme_constant("popup_inset") * factor
	var overlap := get_theme_constant("popup_overlap") * factor
	var available := Rect2i(get_viewport().get_visible_rect()) if menu.is_embedded() else DisplayServer.screen_get_usable_rect(menu.current_screen)
	menu.min_size = Vector2i.ZERO
	menu.size.x = maxi(1, roundi(bounds.size.x - 2 * inset))
	var below := available.end.y - bounds.end.y
	var above := bounds.position.y - available.position.y
	var content_height := ceili(menu.get_contents_minimum_size().y * menu.content_scale_factor)
	var opens_below := content_height <= below or below >= above
	# Both axes must be positive: (0, height) collapses a reopened Window to 1 px.
	menu.max_size = Vector2i(available.size.x, clampi(floori(below if opens_below else above), 1, available.size.y))
	menu.size.y = mini(content_height, menu.max_size.y)
	var x := bounds.position.x + inset
	if is_layout_rtl():
		x = bounds.end.x - inset - menu.size.x
	var y := bounds.end.y - overlap if opens_below else bounds.position.y - menu.size.y
	menu.position = Vector2i(roundi(clampf(x, available.position.x, maxf(available.position.x, available.end.x - menu.size.x))), roundi(clampf(y, available.position.y, maxf(available.position.y, available.end.y - menu.size.y))))
	# Item offsets and the scroll range are rebuilt by the native layout/draw.
	await get_tree().process_frame
	await get_tree().process_frame
	if menu.visible and selected >= 0:
		menu.scroll_to_item(selected)


func _popup_visibility_changed() -> void:
	if not get_popup().visible:
		get_popup().max_size = Vector2i.ZERO
		if is_visible_in_tree() and not disabled:
			grab_focus()


func _enter_tree() -> void:
	preload("res://rookframe/ui/_internal/presentation/binding.gd").attach(self)
