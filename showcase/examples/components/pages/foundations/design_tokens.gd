extends RefCounted
## Every RookframeTokens item of the selected theme. The page iterates the token
## contract, so a new token appears without a page change, and every sample reads
## its value from the Theme again on NOTIFICATION_THEME_CHANGED.

const Tokens = preload("res://rookframe/ui/themes/design_tokens.gd")
const NEUTRAL = preload("res://rookframe/ui/themes/neutral_tokens.tres")
const ICON = preload("res://rookframe/ui/icons/compass.svg")
const SAMPLE := "The expedition sets out at dawn and follows the old road north into the hills."
## Groups of the token specification, matched by name prefix in order. A token
## that matches no group still appears, under "Other tokens".
const COLOR_GROUPS := [
	["Canvas", ["canvas", "scrim"]],
	["Surface", ["surface"]],
	["Content", ["content"]],
	["Border", ["border", "divider", "focus"]],
	["Accent", ["accent"]],
	["Status", ["info", "success", "warning", "danger"]],
	["Tabletop", ["vital", "favorite", "ornament"]],
	["Elevation", ["shadow"]],
]
## Item kinds as `design_tokens.gd` names them in `missing()`.
const KINDS := {
	Theme.DATA_TYPE_COLOR: "colors",
	Theme.DATA_TYPE_CONSTANT: "constants",
	Theme.DATA_TYPE_FONT: "fonts",
	Theme.DATA_TYPE_FONT_SIZE: "font_sizes",
}
const CONSTANT_GROUPS := [
	["Type", ["line_spacing_"]],
	["Space", ["space_"]],
	["Shape", ["radius_", "border_width", "focus_width"]],
	["Elevation", ["elevation_"]],
	["Size", ["target_", "icon_", "action_"]],
	["Motion", ["motion_"]],
]

## A sample that reads its tokens on itself whenever its Theme changes. The
## refresh writes only to descendants, whose own notifications never call it.
class Live extends MarginContainer:
	var refresh: Callable

	func _notification(what: int) -> void:
		if what == NOTIFICATION_THEME_CHANGED and refresh.is_valid():
			refresh.call(self)

	func token_color(token: StringName) -> Color:
		return get_theme_color(token, Tokens.TYPE)

	func token_constant(token: StringName) -> int:
		return get_theme_constant(token, Tokens.TYPE)

## A marker that travels its track for one motion duration. The catalogue's
## reduced motion treats the duration as zero, as the kit does.
class MotionSample extends Live:
	var token: StringName
	var track: Panel
	var marker: ColorRect
	var _tween: Tween
	var reduced_motion := false:
		set(value):
			reduced_motion = value
			restart()

	func restart() -> void:
		if _tween != null:
			_tween.kill()
		if not is_inside_tree() or track == null:
			return
		var travel := track.custom_minimum_size.x - marker.size.x
		if reduced_motion:
			marker.position.x = travel
			return
		var seconds := token_constant(token) / 1000.0
		var transition := token_constant(&"motion_ease") as Tween.TransitionType
		var pause := token_constant(&"motion_slow") / 1000.0
		_tween = create_tween().set_loops()
		_tween.tween_property(marker, "position:x", travel, seconds).from(0.0).set_trans(transition).set_ease(Tween.EASE_IN_OUT)
		_tween.tween_interval(pause)
		_tween.tween_property(marker, "position:x", 0.0, seconds).set_trans(transition).set_ease(Tween.EASE_IN_OUT)
		_tween.tween_interval(pause)

static func build(page) -> void:
	var shown := {}
	var colors := _grouped(Tokens.names(Theme.DATA_TYPE_COLOR), COLOR_GROUPS)
	var constants := _grouped(Tokens.names(Theme.DATA_TYPE_CONSTANT), CONSTANT_GROUPS)

	var palette = _section(page, "Color roles", "Each swatch shows the token name and the value of the selected theme. Godot default defines no tokens, so it shows the neutral set that every theme entry falls back to.")
	for group in COLOR_GROUPS:
		if group[0] == "Elevation" or colors.get(group[0], []).is_empty():
			continue
		var heading = page.label(group[0])
		heading.theme_type_variation = &"RookframeHeading"
		palette.add_child(heading)
		var flow := _flow(palette)
		for token in colors[group[0]]:
			_color_swatch(page, flow, token)
			shown["colors/" + token] = true

	var pairs = _section(page, "Text on its surface", "Each content color must be readable on its surface at WCAG AA, a contrast of %.1f:1." % Tokens.AA_MINIMUM)
	var pair_flow := _flow(pairs)
	for pair in Tokens.AA_PAIRS:
		_contrast_pair(page, pair_flow, pair[0], pair[1])

	var roles = _section(page, "Type roles", "Each role is a font, a font size of the same name and its line_spacing_<role> constant.")
	for role in Tokens.names(Theme.DATA_TYPE_FONT):
		var spacing := StringName("line_spacing_" + role)
		_type_sample(page, roles, role, spacing if Tokens.CONSTANTS.has(spacing) else &"")
		shown["fonts/" + role] = true
		shown["font_sizes/" + role] = true
		shown["constants/" + spacing] = Tokens.CONSTANTS.has(spacing)

	var space = _section(page, "Space", "Gaps and padding. A theme may scale the whole set but keeps its order.")
	for token in constants.get("Space", []):
		_space_sample(page, space, token)
		shown["constants/" + token] = true

	var shape = _section(page, "Shape", "Corner radii, border widths and the focus ring width.")
	var shape_flow := _flow(shape)
	for token in constants.get("Shape", []):
		_shape_sample(page, shape_flow, token)
		shown["constants/" + token] = true

	var elevation = _section(page, "Elevation", "Shadow sizes of raised surfaces and their shadow color. A flat theme sets the sizes to 0.")
	# Raised surfaces cast their shadow on the default surface.
	var elevation_flow := _flow(_ground(elevation, &"surface"))
	for token in constants.get("Elevation", []):
		_elevation_sample(page, elevation_flow, token)
		shown["constants/" + token] = true
	for token in colors.get("Elevation", []):
		_color_swatch(page, elevation_flow, token)
		shown["colors/" + token] = true

	var sizes = _section(page, "Size", "Touch targets, icon sizes and the action height.")
	var size_flow := _flow(sizes)
	for token in constants.get("Size", []):
		_size_sample(page, size_flow, token)
		shown["constants/" + token] = true

	var motion = _section(page, "Motion", "Durations in milliseconds and the transition every duration uses. With reduced motion, every duration is 0.")
	for token in constants.get("Motion", []):
		_motion_sample(page, motion, token)
		shown["constants/" + token] = true

	var others: Array[String] = []
	for data_type in Tokens.data_types():
		for token in Tokens.names(data_type):
			var key: String = KINDS[data_type] + "/" + token
			if not shown.get(key, false):
				others.append(key)
	if not others.is_empty():
		var rest = _section(page, "Other tokens", "Tokens without a sample on this page.")
		for key in others:
			_plain_sample(page, rest, key)

## A catalogue section whose example also falls back to the neutral set, as a
## component theme entry does, when the preview Theme defines no tokens.
static func _section(page, title: String, description: String) -> VBoxContainer:
	var body: VBoxContainer = page.section(title, description)
	body.get_parent().theme = NEUTRAL
	return _ground(body, &"canvas")

## A panel of one surface token, so samples sit on the theme's own ground.
static func _ground(parent: Node, token: StringName) -> VBoxContainer:
	var style := StyleBoxFlat.new()
	var panel := _chip(style)
	var content := VBoxContainer.new()
	panel.add_child(content)
	_add(parent, panel, func(live: Live) -> void:
		style.bg_color = live.token_color(token)
		style.set_corner_radius_all(live.token_constant(&"radius_medium"))
		style.set_content_margin_all(live.token_constant(&"space_5"))
		content.add_theme_constant_override(&"separation", live.token_constant(&"space_4")))
	return content

static func _grouped(names: Array[StringName], groups: Array) -> Dictionary:
	var result := {}
	for token in names:
		var group := "Other"
		for candidate in groups:
			if (candidate[1] as Array).any(func(prefix: String) -> bool: return String(token).begins_with(prefix)):
				group = candidate[0]
				break
		if not result.has(group):
			result[group] = []
		result[group].append(token)
	return result

static func _add(parent: Node, content: Control, refresh: Callable) -> Live:
	var live := Live.new()
	live.refresh = refresh
	live.add_child(content)
	parent.add_child(live)
	refresh.call(live)
	return live

static func _flow(parent: Node) -> HFlowContainer:
	var result := HFlowContainer.new()
	_add(parent, result, func(live: Live) -> void:
		result.add_theme_constant_override(&"h_separation", live.token_constant(&"space_6"))
		result.add_theme_constant_override(&"v_separation", live.token_constant(&"space_5")))
	return result

static func _text(page, parent: Node, copy: String, variation: StringName) -> Label:
	var result: Label = page.label(copy)
	result.theme_type_variation = variation
	result.autowrap_mode = TextServer.AUTOWRAP_OFF
	result.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	parent.add_child(result)
	return result

static func _chip(style: StyleBoxFlat) -> PanelContainer:
	var result := PanelContainer.new()
	result.add_theme_stylebox_override(&"panel", style)
	return result

static func _hex(color: Color) -> String:
	return "#" + color.to_html(color.a < 1.0)

static func _tile(page, title: String) -> Array:
	var stack := VBoxContainer.new()
	stack.add_theme_constant_override(&"separation", 4)
	var name := _text(page, stack, title, &"RookframeLabel")
	name.name = "TokenName"
	return [stack, name]

static func _color_swatch(page, parent: Node, token: StringName) -> void:
	# A content color shows as text on its surface: its AA pair, else the default surface.
	var surface: StringName = &"surface" if String(token).begins_with("content") else &""
	for pair in Tokens.AA_PAIRS:
		if pair[0] == token:
			surface = pair[1]
			break
	var style := StyleBoxFlat.new()
	var chip := _chip(style)
	var sample: Label = null
	if not surface.is_empty():
		sample = _text(page, chip, "Aa on " + surface, &"RookframeBody")
		sample.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		sample.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var tile := _tile(page, token)
	var stack: VBoxContainer = tile[0]
	stack.add_child(chip)
	stack.move_child(chip, 0)
	var value := _text(page, stack, "", &"RookframeMeta")
	value.name = "TokenValue"
	_add(parent, stack, func(live: Live) -> void:
		var color := live.token_color(token)
		style.bg_color = live.token_color(surface) if sample != null else color
		style.border_color = live.token_color(&"border")
		style.set_border_width_all(live.token_constant(&"border_width"))
		style.set_corner_radius_all(live.token_constant(&"radius_small"))
		style.set_content_margin_all(live.token_constant(&"space_2"))
		chip.custom_minimum_size = Vector2(live.token_constant(&"space_8") * 2.5, live.token_constant(&"space_7"))
		if sample != null:
			sample.add_theme_color_override(&"font_color", color)
		value.text = _hex(color))

static func _contrast_pair(page, parent: Node, foreground: StringName, background: StringName) -> void:
	var style := StyleBoxFlat.new()
	var chip := _chip(style)
	var stack := VBoxContainer.new()
	chip.add_child(stack)
	var title := _text(page, stack, "%s on %s" % [foreground, background], &"RookframeBody")
	var ratio := _text(page, stack, "", &"RookframeMeta")
	ratio.name = "ContrastRatio"
	_add(parent, chip, func(live: Live) -> void:
		var ink := live.token_color(foreground)
		var paper := live.token_color(background)
		style.bg_color = paper
		style.border_color = live.token_color(&"border")
		style.set_border_width_all(live.token_constant(&"border_width"))
		style.set_corner_radius_all(live.token_constant(&"radius_medium"))
		style.set_content_margin_all(live.token_constant(&"space_4"))
		chip.custom_minimum_size.x = live.token_constant(&"space_8") * 4
		var contrast := Tokens.contrast_ratio(ink, paper)
		ratio.text = "%.2f:1 · %s" % [contrast, "meets AA" if contrast >= Tokens.AA_MINIMUM else "below AA"]
		for label in [title, ratio]:
			label.add_theme_color_override(&"font_color", ink))

static func _type_sample(page, parent: Node, role: StringName, spacing: StringName) -> void:
	var stack := VBoxContainer.new()
	var meta := _text(page, stack, "", &"RookframeMeta")
	meta.name = "TokenName"
	var sample: Label = page.label(SAMPLE)
	stack.add_child(sample)
	_add(parent, stack, func(live: Live) -> void:
		var font := live.get_theme_font(role, Tokens.TYPE)
		var size := live.get_theme_font_size(role, Tokens.TYPE)
		var lines := live.token_constant(spacing) if not spacing.is_empty() else 0
		sample.add_theme_font_override(&"font", font)
		sample.add_theme_font_size_override(&"font_size", size)
		sample.add_theme_constant_override(&"line_spacing", lines)
		var parts := PackedStringArray([role, "%d px" % size])
		if not spacing.is_empty():
			parts.append("%s %+d px" % [spacing, lines])
		parts.append(font.get_font_name() if font != null and not font.get_font_name().is_empty() else "Godot default font")
		meta.text = "  ·  ".join(parts))

static func _space_sample(page, parent: Node, token: StringName) -> void:
	var row := HBoxContainer.new()
	var label := _text(page, row, "", &"RookframeLabel")
	label.name = "TokenName"
	var bar := ColorRect.new()
	bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(bar)
	_add(parent, row, func(live: Live) -> void:
		var value := live.token_constant(token)
		label.custom_minimum_size.x = live.token_constant(&"space_8") * 3
		label.text = "%s · %d px" % [token, value]
		bar.color = live.token_color(&"accent")
		bar.custom_minimum_size = Vector2(value, live.token_constant(&"space_4")))

static func _value_tile(page, parent: Node, token: StringName, sample: Control, refresh: Callable) -> void:
	var tile := _tile(page, token)
	var stack: VBoxContainer = tile[0]
	stack.add_child(sample)
	stack.move_child(sample, 0)
	var value := _text(page, stack, "", &"RookframeMeta")
	value.name = "TokenValue"
	_add(parent, stack, func(live: Live) -> void:
		refresh.call(live)
		value.text = "%d px" % live.token_constant(token))

static func _shape_sample(page, parent: Node, token: StringName) -> void:
	var style := StyleBoxFlat.new()
	var chip := _chip(style)
	_value_tile(page, parent, token, chip, func(live: Live) -> void:
		var value := live.token_constant(token)
		var radius := String(token).begins_with("radius_")
		var focus := String(token).begins_with("focus")
		style.bg_color = live.token_color(&"surface_raised")
		style.border_color = live.token_color(&"focus_ring" if focus else &"border_strong")
		style.set_border_width_all(live.token_constant(&"border_width") if radius else value)
		style.set_corner_radius_all(value if radius else live.token_constant(&"radius_medium"))
		chip.custom_minimum_size = Vector2(live.token_constant(&"space_8") * 2, live.token_constant(&"space_7")))

static func _elevation_sample(page, parent: Node, token: StringName) -> void:
	var style := StyleBoxFlat.new()
	var chip := _chip(style)
	_value_tile(page, parent, token, chip, func(live: Live) -> void:
		style.bg_color = live.token_color(&"surface_raised")
		style.shadow_color = live.token_color(&"shadow")
		style.shadow_size = live.token_constant(token)
		style.set_corner_radius_all(live.token_constant(&"radius_medium"))
		chip.custom_minimum_size = Vector2(live.token_constant(&"space_8") * 2, live.token_constant(&"space_7")))

static func _size_sample(page, parent: Node, token: StringName) -> void:
	if String(token).begins_with("icon_"):
		var icon := TextureRect.new()
		icon.texture = ICON
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		_value_tile(page, parent, token, icon, func(live: Live) -> void:
			var value := live.token_constant(token)
			icon.custom_minimum_size = Vector2(value, value)
			icon.self_modulate = live.token_color(&"content"))
		return
	var style := StyleBoxFlat.new()
	var chip := _chip(style)
	chip.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	_value_tile(page, parent, token, chip, func(live: Live) -> void:
		var value := live.token_constant(token)
		style.bg_color = live.token_color(&"surface_sunken")
		style.border_color = live.token_color(&"border_strong")
		style.set_border_width_all(live.token_constant(&"border_width"))
		style.set_corner_radius_all(live.token_constant(&"radius_small"))
		var wide := String(token).begins_with("action_")
		chip.custom_minimum_size = Vector2(live.token_constant(&"space_8") * 3 if wide else value, value))

static func _motion_sample(page, parent: Node, token: StringName) -> void:
	var row := HBoxContainer.new()
	var label := _text(page, row, "", &"RookframeLabel")
	label.name = "TokenName"
	if token == &"motion_ease":
		_add(parent, row, func(reader: Live) -> void:
			label.text = "%s · %s" % [token, _transition_name(reader.token_constant(token))])
		return
	var sample := MotionSample.new()
	sample.token = token
	sample.reduced_motion = page.reduced_motion
	sample.track = Panel.new()
	sample.track.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var track_style := StyleBoxFlat.new()
	sample.track.add_theme_stylebox_override(&"panel", track_style)
	sample.marker = ColorRect.new()
	sample.track.add_child(sample.marker)
	row.add_child(sample.track)
	sample.add_child(row)
	sample.refresh = func(live: Live) -> void:
		var marker_size := live.token_constant(&"space_4")
		label.custom_minimum_size.x = live.token_constant(&"space_8") * 4
		label.text = "%s · %d ms" % [token, live.token_constant(token)]
		track_style.bg_color = live.token_color(&"divider")
		track_style.set_corner_radius_all(live.token_constant(&"radius_full"))
		sample.track.custom_minimum_size = Vector2(live.token_constant(&"space_8") * 4, marker_size)
		sample.marker.color = live.token_color(&"accent")
		sample.marker.size = Vector2(marker_size, marker_size)
		sample.restart()
	parent.add_child(sample)
	sample.refresh.call(sample)

static func _transition_name(value: int) -> String:
	for constant in ClassDB.class_get_enum_constants(&"Tween", &"TransitionType"):
		if ClassDB.class_get_integer_constant(&"Tween", constant) == value:
			return constant.trim_prefix("TRANS_").capitalize()
	return str(value)

static func _plain_sample(page, parent: Node, key: String) -> void:
	var kind := key.get_slice("/", 0)
	var token := StringName(key.get_slice("/", 1))
	var row := HBoxContainer.new()
	var label := _text(page, row, "", &"RookframeLabel")
	label.name = "TokenName"
	_add(parent, row, func(live: Live) -> void:
		var value: Variant
		match kind:
			"colors": value = _hex(live.token_color(token))
			"constants": value = live.token_constant(token)
			"fonts": value = live.get_theme_font(token, Tokens.TYPE).get_font_name()
			"font_sizes": value = live.get_theme_font_size(token, Tokens.TYPE)
		label.text = "%s · %s" % [token, value])
