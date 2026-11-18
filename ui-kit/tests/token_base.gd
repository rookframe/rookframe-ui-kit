extends SceneTree
## The token-built base layer completes every theme entry: each standard stock
## control and kit variation resolves from the entry, every value follows the
## tokens, its text meets WCAG AA, interactive states differ, and a type a theme
## defines stays its own.
const Tokens = preload("res://rookframe/ui/themes/design_tokens.gd")
const TokenBase = preload("res://rookframe/ui/themes/token_base.gd")
const ComponentTheme = preload("res://rookframe/ui/themes/component_theme.gd")
const NEUTRAL = preload("res://rookframe/ui/themes/neutral_tokens.tres")
const THEMES = "res://rookframe/ui/themes"
const STOCK: Array[StringName] = [
	&"Button", &"MenuButton", &"OptionButton", &"CheckBox", &"CheckButton", &"LinkButton", &"MenuBar",
	&"LineEdit", &"TextEdit", &"SpinBox", &"Label", &"RichTextLabel", &"TooltipLabel", &"TooltipPanel",
	&"Panel", &"PanelContainer", &"PopupPanel", &"PopupMenu", &"AcceptDialog", &"Window",
	&"TabBar", &"TabContainer", &"ItemList", &"Tree", &"FileDialog", &"FoldableContainer",
	&"HScrollBar", &"VScrollBar", &"ScrollContainer", &"HSlider", &"VSlider", &"ProgressBar",
	&"HSeparator", &"VSeparator",
	&"HBoxContainer", &"VBoxContainer", &"HFlowContainer", &"VFlowContainer", &"GridContainer",
]
## Names the kit reads that are not standard variations of the base layer:
## the token type, and the native mapping compiler's usages, which resolve
## through their stock class.
const OUTSIDE := ["RookframeTokens"]
## Variations the layer declares for Packages and hosts although no kit source
## assigns them, with their base type.
const DECLARED := {&"RookframeBodyMuted": &"Label", &"RookframeTextStack": &"VBoxContainer"}
const INTERACTIVE: Array[StringName] = [
	&"Button", &"OptionButton", &"RookframeSecondaryButton", &"RookframePrimaryButton",
	&"RookframeQuietButton", &"RookframeDangerButton", &"RookframeTabButton", &"RookframeChoiceRow",
]
var failures: Array[String] = []

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	var neutral := ComponentTheme.new()
	var base := TokenBase.build(NEUTRAL)
	_coverage(base)
	_complete("Neutral entry", neutral, base, Theme.new())
	_readable("Neutral entry", neutral, base)
	_derived()
	_states(neutral, PackedStringArray())
	_ownership()
	await _compact_field(neutral)
	for directory in DirAccess.get_directories_at(THEMES):
		var path := THEMES.path_join(directory).path_join("theme.tres")
		if ResourceLoader.exists(path):
			var entry: Theme = load(path)
			var authored := Theme.new()
			for source in entry.supplemental_themes + [entry.native_theme]:
				if source != null:
					authored.merge_with(source)
			var layer := TokenBase.build(entry)
			_complete(path, entry, layer, authored)
			_readable(path, entry, layer)
			_states(entry, authored.get_type_list())
	for failure in failures:
		push_error(failure)
	print("TOKEN_BASE: %d types; %d failures" % [base.get_type_list().size(), failures.size()])
	quit(0 if failures.is_empty() else 1)

func check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

## The layer names every listed stock control with real native items, and
## every variation a kit scene or script assigns.
func _coverage(base: Theme) -> void:
	var types := base.get_type_list()
	var native := ThemeDB.get_default_theme()
	for type in STOCK:
		check(types.has(type), "Base layer styles stock control " + type)
		for data_type in Theme.DATA_TYPE_MAX:
			for item in base.get_theme_item_list(data_type, type):
				check(_native(native, data_type, item, type), "%s/%s is a native item" % [type, item])
	var pattern := RegEx.create_from_string("(?:theme_type_variation = &?|&)\"((?:Rookframe|Task|Wizard)[A-Z]\\w*|components_button\\w*)\"")
	var used := {}
	_scan("res://rookframe/ui/components", pattern, used)
	_scan("res://rookframe/ui/_internal", pattern, used)
	check(used.size() > 60, "Kit sources name their variations")
	for name: StringName in DECLARED:
		check(base.get_type_variation_base(name) == DECLARED[name], "Base layer declares %s on %s" % [name, DECLARED[name]])
	for name: String in used:
		if not name in OUTSIDE:
			check(types.has(name), "Base layer declares the kit variation %s (%s)" % [name, used[name]])

## Godot declares the item for the control or a class it extends. Buttons also
## read `hover_pressed`, which the default Theme leaves out.
func _native(native: Theme, data_type: int, item: StringName, type: StringName) -> bool:
	var current := {&"TooltipLabel": &"Label", &"TooltipPanel": &"PanelContainer"}.get(type, type) as StringName
	while not current.is_empty():
		if native.has_theme_item(data_type, item, current):
			return true
		current = ClassDB.get_parent_class(current)
	return item == &"hover_pressed" and ClassDB.is_parent_class(type, &"Button")

func _scan(directory: String, pattern: RegEx, used: Dictionary) -> void:
	for file in DirAccess.get_files_at(directory):
		if file.get_extension() in ["tscn", "gd"]:
			var path := directory.path_join(file)
			for found in pattern.search_all(FileAccess.get_file_as_string(path)):
				used[found.get_string(1)] = path
	for child in DirAccess.get_directories_at(directory):
		_scan(directory.path_join(child), pattern, used)

## Every base type resolves from the entry itself, never from Godot's defaults,
## and nothing the theme authored was replaced.
func _complete(label: String, entry: Theme, base: Theme, authored: Theme) -> void:
	var owned := authored.get_type_list()
	for type in base.get_type_list():
		check(entry.get_type_list().has(type), "%s resolves %s" % [label, type])
		if owned.has(type):
			continue
		check(entry.get_type_variation_base(type) == base.get_type_variation_base(type), "%s: %s keeps its base type" % [label, type])
		for data_type in Theme.DATA_TYPE_MAX:
			for item in base.get_theme_item_list(data_type, type):
				check(entry.has_theme_item(data_type, item, type), "%s defines %s/%s" % [label, type, item])
	for type in owned:
		check(entry.get_type_variation_base(type) == authored.get_type_variation_base(type), "%s: authored %s keeps its base type" % [label, type])
		for data_type in Theme.DATA_TYPE_MAX:
			var items := entry.get_theme_item_list(data_type, type)
			check(items.size() == authored.get_theme_item_list(data_type, type).size(), "%s: the base layer adds nothing to authored %s" % [label, type])
			for item in items:
				check(is_same(entry.get_theme_item(data_type, item, type), authored.get_theme_item(data_type, item, type)), "%s: authored %s/%s wins" % [label, type, item])

## Text the base layer builds from an entry's tokens meets WCAG AA, including
## types the theme authors itself, which would fall back to the layer without
## their source: every label variation on `surface`, and every Button ink on its
## own state fill, translucent fills seen over `surface`. That covers
## `danger_content` on the destructive hover and pressed fills, which mix
## `danger` into `danger_surface`. Disabled ink is exempt.
func _readable(label: String, entry: Theme, base: Theme) -> void:
	var surface := entry.get_color(&"surface", Tokens.TYPE)
	for type in base.get_type_list():
		var kind := base.get_type_variation_base(type)
		if kind == &"Label" and base.has_color(&"font_color", type):
			_aa(label, type, "text", base.get_color(&"font_color", type), surface)
		elif kind == &"Button" or ClassDB.is_parent_class(type, &"Button"):
			for state: StringName in [&"normal", &"hover", &"pressed"]:
				var box := base.get_stylebox(state, type) as StyleBoxFlat
				if box == null or not base.has_color(_ink(state), type):
					continue
				var fill := surface.lerp(Color(box.bg_color, 1.0), box.bg_color.a if box.draw_center else 0.0)
				_aa(label, type, state, base.get_color(_ink(state), type), fill)

func _ink(state: StringName) -> StringName:
	return &"font_color" if state == &"normal" else StringName("font_%s_color" % state)

func _aa(label: String, type: StringName, state: String, ink: Color, fill: Color) -> void:
	var ratio := Tokens.contrast_ratio(ink, fill)
	check(ratio >= Tokens.AA_MINIMUM, "%s: %s %s ink #%s on #%s is %.2f:1" % [label, type, state, ink.to_html(false), fill.to_html(false), ratio])

## No color, size or font is fixed: change every token and every value follows.
func _derived() -> void:
	var shifted := Theme.new()
	shifted.merge_with(NEUTRAL)
	for item in Tokens.COLORS:
		var color: Color = Tokens.COLORS[item]
		shifted.set_color(item, Tokens.TYPE, Color(1.0 - color.r, 1.0 - color.g, 1.0 - color.b, color.a))
	for item in Tokens.FONT_SIZES:
		shifted.set_font_size(item, Tokens.TYPE, Tokens.FONT_SIZES[item] + 7)
	var font := SystemFont.new()
	for item in Tokens.FONTS:
		shifted.set_font(item, Tokens.TYPE, font)
	var first := TokenBase.build(NEUTRAL)
	var second := TokenBase.build(shifted)
	for type in first.get_type_list():
		for item in first.get_color_list(type):
			check(first.get_color(item, type) != second.get_color(item, type), "%s/%s follows its color role" % [type, item])
		for item in first.get_font_size_list(type):
			check(first.get_font_size(item, type) != second.get_font_size(item, type), "%s/%s follows its type role" % [type, item])
		for item in first.get_font_list(type):
			# Emphasis is a FontVariation over the role's own face.
			var face := second.get_font(item, type)
			check(face == font or (face is FontVariation and face.base_font == font), "%s/%s follows its type role" % [type, item])
		for item in first.get_stylebox_list(type):
			var before := _paint(first.get_stylebox(item, type))
			var after := _paint(second.get_stylebox(item, type))
			for index in before.size():
				check(before[index] != after[index], "%s/%s follows its color roles" % [type, item])

## Colors a StyleBox draws with.
func _paint(box: StyleBox) -> Array[Color]:
	var colors: Array[Color] = []
	if box is StyleBoxFlat:
		colors.append(box.bg_color)
		if box.border_width_left + box.border_width_top + box.border_width_right + box.border_width_bottom > 0:
			colors.append(box.border_color)
		if box.shadow_size > 0:
			colors.append(box.shadow_color)
	elif box is StyleBoxLine:
		colors.append(box.color)
	return colors

## Normal, hover, pressed, disabled and focus are told apart wherever the base layer draws them.
func _states(entry: Theme, owned: PackedStringArray) -> void:
	for type in INTERACTIVE:
		if owned.has(type):
			continue
		var seen := {}
		for state: StringName in [&"normal", &"hover", &"pressed", &"disabled", &"focus"]:
			var box := entry.get_stylebox(state, type) as StyleBoxFlat
			# A control without a frame shows its state in its text and icon.
			var ink := entry.get_color(&"font_color" if state == &"normal" else StringName("font_%s_color" % state), type)
			var key := "%s %s %s %s" % [box.bg_color if box.draw_center else Color(), box.border_color, box.get_border_width_min(), ink]
			check(not seen.has(key), "%s: %s differs from %s" % [type, state, seen.get(key, "")])
			seen[key] = state

## A compact task field really is denser where no theme presents it: a field
## that ignores `compact` overflows the phone sheets that rely on it.
func _compact_field(entry: Theme) -> void:
	var host := Control.new()
	host.theme = entry
	root.add_child(host)
	var areas: Array[Control] = []
	for compact in [false, true]:
		var area: Control = load("res://rookframe/ui/components/forms/task_text_area.tscn").instantiate()
		area.compact = compact
		host.add_child(area)
		areas.append(area)
	await process_frame
	check(areas[1].get_node(^"Editor").custom_minimum_size.y < areas[0].get_node(^"Editor").custom_minimum_size.y, "A compact task area has a shorter editor")
	check(areas[1].get_theme_constant(&"separation") < areas[0].get_theme_constant(&"separation"), "A compact task area closes its gaps")
	check(areas[1].get_node(^"Editor").custom_minimum_size.y >= entry.get_constant(&"target_minimum", Tokens.TYPE), "A compact task area keeps the touch target")
	host.free()

## A type a theme defines is that theme's alone; the rest still fills.
func _ownership() -> void:
	var partial := Theme.new()
	var mine := StyleBoxEmpty.new()
	partial.set_stylebox(&"normal", &"Button", mine)
	partial.set_type_variation(&"RookframeSurface", &"Panel")
	partial.set_color(&"accent", Tokens.TYPE, Color.RED)
	var entry := ComponentTheme.new()
	entry.native_theme = partial
	check(entry.get_stylebox(&"normal", &"Button") == mine, "An authored item wins")
	check(not entry.has_stylebox(&"hover", &"Button"), "The base layer adds no item to an authored type")
	check(entry.get_type_variation_base(&"RookframeSurface") == &"Panel", "An authored variation keeps its base")
	check(not entry.has_stylebox(&"panel", &"RookframeSurface"), "An authored variation inherits from its own base")
	check(entry.get_type_variation_base(&"RookframePrimaryButton") == &"Button", "Variations of an authored type remain declared")
	check((entry.get_stylebox(&"normal", &"RookframePrimaryButton") as StyleBoxFlat).bg_color == Color.RED, "The base layer reads the entry's own tokens")
	entry.native_theme = null
	check(entry.has_stylebox(&"hover", &"Button"), "Removing the source restores the base layer")
	check((entry.get_stylebox(&"normal", &"RookframePrimaryButton") as StyleBoxFlat).bg_color == Tokens.COLORS[&"accent"], "The base layer follows the rebuilt tokens")
