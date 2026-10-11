@tool
extends Theme
## Adapter only. Resolved native Theme values are derived from reference mappings.
## Never author colors, dimensions, typography or state treatments in this file.
const Usage = preload("menu_usage.gd")
const State = preload("menu_state.gd")
const Mapping = preload("menu_theme_map.gd")
const Materials = preload("materials/menu_materials.gd")

func _init(mapping: Script = Mapping, materials: Script = Materials) -> void:
	default_font = materials.value(mapping.DEFAULTS.font)
	default_font_size = materials.value(mapping.DEFAULTS.font_size)
	var elements: Dictionary = mapping.ELEMENTS.duplicate()
	elements.merge(preload("settings_theme_map.gd").ELEMENTS)
	elements.merge(preload("switch_theme_map.gd").ELEMENTS)
	elements.merge(preload("../editor/editor_theme_map.gd").ELEMENTS)
	for usage in elements:
		var properties: Dictionary = elements[usage]
		var native_usage := native_type(usage)
		set_type_variation(native_usage, native_type(properties.base_type))
		for property in properties:
			if property == "base_type":
				continue
			var path: PackedStringArray = property.split("/")
			var value: Variant = materials.value(properties[property])
			match path[0]:
				"fonts": set_font(path[1], native_usage, value)
				"font_sizes": set_font_size(path[1], native_usage, value)
				"colors": set_color(path[1], native_usage, value)
				"constants": set_constant(path[1], native_usage, value)
				"styles": set_stylebox(path[1], native_usage, value)
				"icons": set_icon(path[1], native_usage, value)
	for usage in [Usage.PRIMARY, Usage.STANDARD, Usage.DESTRUCTIVE]:
		for compact in [false, true]:
			_compile_button(usage, compact, mapping, materials)

static func native_type(usage: StringName) -> StringName:
	# Godot Theme requires identifier-safe names; semantic tokens retain dots.
	return StringName(String(usage).replace(".", "_").replace("@", "__"))

static func button_variant(usage: StringName, compact: bool) -> StringName:
	return native_type(StringName(String(usage) + "@compact") if compact else usage)

func _compile_button(usage: StringName, compact: bool, mapping: Script, materials: Script) -> void:
	var density: StringName = State.COMPACT if compact else State.REGULAR
	var variant := button_variant(usage, compact)
	set_type_variation(variant, &"Button")
	var resting: Dictionary = mapping.button(usage, State.button(State.ENABLED, State.RESTING, State.UNFOCUSED, density))
	set_font("font", variant, materials.value(resting.font))
	set_font_size("font_size", variant, materials.value(resting.font_size))
	for property in ["h_separation", "icon_max_width", "outline_size", "minimum_height"]:
		if resting.has(property):
			set_constant(property, variant, materials.value(resting[property]))
	for property in ["texture_visible", "hover_ms", "press_ms", "release_ms", "transition", "ease", "cap_depth", "shadow_drop", "patch_side", "patch_rail", "ornament_width", "ornament_height", "ornament_travel", "ornament_ms", "ornament_rest", "icons_visible", "groove_size", "groove_offset_x", "groove_offset_y", "groove_shadow_size"]:
		set_constant(property, variant, materials.value(resting[property]))
	for property in ["cap", "adornment"]:
		set_icon(property, variant, materials.value(resting[property]))
	for property in ["cap_tint", "edge_tint", "shadow_tint", "groove_color", "cut_edge_color"]:
		set_color(property, variant, materials.value(resting[property]))
	set_color("rest_tint", variant, materials.value(resting.get("rest_tint", resting.cap_tint)))
	# Godot provides orthogonal focus rendering and the native input state machine.
	# Each native draw slot is a projection of the semantic state dimensions.
	var slots := {
		"normal": State.button(State.ENABLED, State.RESTING, State.UNFOCUSED, density),
		"hover": State.button(State.ENABLED, State.HOVERED, State.UNFOCUSED, density),
		"pressed": State.button(State.ENABLED, State.PRESSED, State.UNFOCUSED, density),
		"hover_pressed": State.button(State.ENABLED, State.PRESSED, State.UNFOCUSED, density, State.INSIDE),
		"disabled": State.button(State.DISABLED, State.RESTING, State.UNFOCUSED, density),
	}
	for slot in slots:
		var references: Dictionary = mapping.button(usage, slots[slot])
		var style := StyleBoxFlat.new()
		for component in ["surface", "border", "padding"]:
			var values: Dictionary = materials.value(references[component])
			for property in values:
				style.set(property, values[property])
		set_stylebox(slot, variant, style)
		var label_slot: String = "font_color" if slot == "normal" else "font_" + slot + "_color"
		set_color(label_slot, variant, materials.value(references.label))
		if references.has("icon"):
			set_color("icon_" + slot + "_color", variant, materials.value(references.icon))
	var focused: Dictionary = mapping.button(usage, State.button(State.ENABLED, State.RESTING, State.FOCUSED, density))
	set_stylebox("focus", variant, materials.value(focused.focus))
	set_color("font_focus_color", variant, materials.value(focused.label))
	if focused.has("icon"):
		set_color("icon_focus_color", variant, materials.value(focused.icon))
