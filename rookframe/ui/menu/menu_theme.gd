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
	elements.merge(preload("../chronicle/chronicle_theme_map.gd").ELEMENTS)
	elements.merge(preload("world_list_theme_map.gd").ELEMENTS)
	elements.merge(preload("world_toolbar_theme_map.gd").ELEMENTS)
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
	for usage in [Usage.PRIMARY, Usage.STANDARD, Usage.DESTRUCTIVE, &"components.button", &"components.button.primary"]:
		for compact in [false, true]:
			_compile_button(usage, compact, mapping, materials)

	set_icon("arrow", &"OptionButton", get_icon("arrow", &"settings_choice"))
	for item in ["arrow_margin", "modulate_arrow"]:
		set_constant(item, &"OptionButton", get_constant(item, &"settings_choice"))

static func native_type(usage: StringName) -> StringName:
	# Godot Theme requires identifier-safe names; semantic tokens retain dots.
	return StringName(String(usage).replace(".", "_").replace("@", "__"))

static func button_variant(usage: StringName, compact: bool) -> StringName:
	return native_type(StringName(String(usage) + "@compact") if compact else usage)

func _compile_button(usage: StringName, compact: bool, mapping: Script, materials: Script) -> void:
	var density: StringName = State.COMPACT if compact else State.REGULAR
	var variant := button_variant(usage, compact)
	set_type_variation(variant, button_variant(&"components.button", compact) if usage == &"components.button.primary" else &"Button")
	var resting: Dictionary = button_references(mapping, usage, State.button(State.ENABLED, State.RESTING, State.UNFOCUSED, density))
	if resting.has("font"):
		set_font("font", variant, materials.value(resting.font))
	if resting.has("font_size"):
		set_font_size("font_size", variant, materials.value(resting.font_size))
	for property in ["h_separation", "icon_max_width", "outline_size", "minimum_height"]:
		if resting.has(property):
			set_constant(property, variant, materials.value(resting[property]))
	for property in ["texture_visible", "hover_ms", "press_ms", "release_ms", "transition", "ease", "cap_depth", "shadow_drop", "patch_side", "patch_rail", "ornament_width", "ornament_height", "ornament_travel", "ornament_ms", "ornament_rest", "icons_visible", "groove_size", "groove_offset_x", "groove_offset_y", "groove_shadow_size"]:
		if resting.has(property):
			set_constant(property, variant, materials.value(resting[property]))
	for property in ["cap", "adornment"]:
		if resting.has(property):
			set_icon(property, variant, materials.value(resting[property]))
	for property in ["cap_tint", "rest_tint", "edge_tint", "shadow_tint", "groove_color", "cut_edge_color"]:
		if resting.has(property):
			set_color(property, variant, materials.value(resting[property]))
	if resting.has("cap_tint") and not resting.has("rest_tint"):
		set_color("rest_tint", variant, materials.value(resting.cap_tint))
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
		var references: Dictionary = button_references(mapping, usage, slots[slot])
		# StyleBoxes are native Theme items. A mapped face replaces that item;
		# unmapped slots inherit it through the native type-variation chain.
		if references.has("surface") or references.has("border") or references.has("padding"):
			var face_references: Dictionary = button_references(mapping, &"components.button", slots[slot])
			face_references.merge(references, true)
			var style := StyleBoxFlat.new()
			for component in ["surface", "border", "padding"]:
				var values: Dictionary = materials.value(face_references[component])
				for property in values:
					style.set(property, values[property])
			set_stylebox(slot, variant, style)
		if references.has("label"):
			var label_slot: String = "font_color" if slot == "normal" else "font_" + slot + "_color"
			set_color(label_slot, variant, materials.value(references.label))
		if references.has("icon"):
			set_color("icon_" + slot + "_color", variant, materials.value(references.icon))
	var focused := button_references(mapping, usage, State.button(State.ENABLED, State.RESTING, State.FOCUSED, density))
	if focused.has("focus"):
		set_stylebox("focus", variant, materials.value(focused.focus))
	if focused.has("label"):
		set_color("font_focus_color", variant, materials.value(focused.label))
	if focused.has("icon"):
		set_color("icon_focus_color", variant, materials.value(focused.icon))

## Compare Material references, not values: distinct semantic tokens must remain
## overrides even when their current concrete values happen to match.
static func button_references(mapping: Script, usage: StringName, state: Dictionary) -> Dictionary:
	if usage not in [&"components.button", &"components.button.primary"]:
		return mapping.button(usage, state)
	var standard: Dictionary = mapping.button(Usage.STANDARD, state)
	if usage == &"components.button":
		return standard
	var primary: Dictionary = mapping.button(Usage.PRIMARY, state)
	for property in primary.keys():
		if standard.get(property) == primary[property]:
			primary.erase(property)
	return primary

## Apply ordered usages to any stock Control. Only explicitly authored Theme
## items are copied into each layer; Godot performs the property fallback.
static func apply_usages(control: Control, usages: Array[StringName], compact: bool = false) -> void:
	var owner: Node = control
	var variant: StringName = control.get_class()
	while owner != null:
		if (owner is Control or owner is Window) and owner.theme != null:
			variant = usage_variant(owner.theme, usages, control.get_class(), compact)
		owner = owner.get_parent()
	if control.theme_type_variation != variant:
		control.theme_type_variation = variant

static func usage_variant(target: Theme, usages: Array[StringName], base_type: StringName, compact: bool = false) -> StringName:
	var parent := base_type
	var prefix := "Usage_" + String(base_type) + ("_compact" if compact else "_regular")
	for usage in usages:
		# Include the complete ordered prefix: the same token can follow a
		# primary or a standard button without changing either other's base.
		prefix += "_" + String(usage).to_utf8_buffer().hex_encode()
		var variant := StringName(prefix)
		if target.get_type_variation_base(variant) != parent:
			target.set_type_variation(variant, parent)
		var sources: Array[StringName] = [native_type(usage)]
		if compact:
			sources.append(button_variant(usage, true))
		for data_type in Theme.DATA_TYPE_MAX:
			var items: Dictionary = {}
			for source in sources:
				for item in target.get_theme_item_list(data_type, source):
					items[item] = target.get_theme_item(data_type, item, source)
			for item in target.get_theme_item_list(data_type, variant):
				if not items.has(item):
					target.clear_theme_item(data_type, item, variant)
			for item in items:
				if not target.has_theme_item(data_type, item, variant) or target.get_theme_item(data_type, item, variant) != items[item]:
					target.set_theme_item(data_type, item, variant, items[item])
		parent = variant
	return parent

## Complete a composed World Theme without overriding authored tooltip items.
## The source remains sparse so native Theme changes can refresh these defaults.
static func apply_world_tooltips(target: Theme, authored: Theme) -> void:
	if not authored.has_stylebox("panel", &"TooltipPanel"):
		target.set_stylebox("panel", &"TooltipPanel", target.get_stylebox("panel", &"editor_surface_inset"))
	if not authored.has_font("font", &"TooltipLabel"):
		target.set_font("font", &"TooltipLabel", target.get_font("font", &"editor_meta"))
	if not authored.has_font_size("font_size", &"TooltipLabel"):
		target.set_font_size("font_size", &"TooltipLabel", target.get_font_size("font_size", &"editor_meta"))
	if not authored.has_color("font_color", &"TooltipLabel"):
		target.set_color("font_color", &"TooltipLabel", target.get_color("font_color", &"editor_body"))
