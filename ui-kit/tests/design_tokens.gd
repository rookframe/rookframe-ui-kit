extends SceneTree
## Every theme defines every semantic token, and readable token pairs meet WCAG AA.
## A theme entry that omits a token still resolves it to the neutral default.
const Tokens = preload("res://rookframe/ui/themes/design_tokens.gd")
const ComponentTheme = preload("res://rookframe/ui/themes/component_theme.gd")
const NEUTRAL = preload("res://rookframe/ui/themes/neutral_tokens.tres")
const THEMES = "res://rookframe/ui/themes"
## Installed theme entries only report their gaps until every entry defines every token.
const ENFORCE_THEME_ENTRIES := true
var failures: Array[String] = []

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	_contract()
	_audit("Neutral set", NEUTRAL, NEUTRAL, true)
	_fallback()
	for directory in DirAccess.get_directories_at(THEMES):
		var path := THEMES.path_join(directory).path_join("theme.tres")
		if ResourceLoader.exists(path):
			var entry: Theme = load(path)
			_audit(path, _authored(entry), entry, ENFORCE_THEME_ENTRIES)
	for failure in failures:
		push_error(failure)
	print("DESIGN_TOKENS: %d failures" % failures.size())
	quit(0 if failures.is_empty() else 1)

func check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _contract() -> void:
	check(Tokens.COLORS.size() == 39, "The contract declares 38 color roles plus shadow")
	for role in Tokens.FONTS:
		check(Tokens.FONT_SIZES.has(role) and Tokens.CONSTANTS.has(StringName("line_spacing_" + role)), "Type role %s has a font size and line spacing" % role)
	check(Tokens.FONT_SIZES.size() == Tokens.FONTS.size(), "Every font size belongs to a type role")

## `authored` must define every token; `effective` is what Controls resolve.
func _audit(label: String, authored: Theme, effective: Theme, enforced: bool) -> void:
	var gaps := Tokens.missing(authored)
	var contrast := Tokens.contrast_failures(effective)
	var problems: Array[String] = []
	if not gaps.is_empty():
		problems.append("%s lacks %d tokens: %s" % [label, gaps.size(), ", ".join(gaps)])
	if not contrast.is_empty():
		problems.append("%s is below AA: %s" % [label, "; ".join(contrast)])
	if enforced:
		failures.append_array(problems)
	else:
		for problem in problems:
			print("PENDING: ", problem)

## Items a component theme entry authors itself, without the neutral layer it merges.
func _authored(entry: Theme) -> Theme:
	if entry.get(&"native_theme") == null and entry.get(&"supplemental_themes") == null:
		return entry
	var authored := Theme.new()
	for source in entry.supplemental_themes + [entry.native_theme]:
		if source != null:
			authored.merge_with(source)
	return authored

func _fallback() -> void:
	var partial := Theme.new()
	partial.set_color(&"accent", Tokens.TYPE, Color.RED)
	partial.set_constant(&"space_1", Tokens.TYPE, 5)
	var entry := ComponentTheme.new()
	entry.native_theme = partial
	var host := Control.new()
	host.theme = entry
	# A nearer plain Theme without tokens hides none of them.
	var probe := Label.new()
	probe.theme = Theme.new()
	host.add_child(probe)
	root.add_child(host)
	check(probe.get_theme_color(&"accent", Tokens.TYPE) == Color.RED, "An authored color overrides the neutral default")
	check(probe.get_theme_constant(&"space_1", Tokens.TYPE) == 5, "An authored constant overrides the neutral default")
	for item in Tokens.COLORS:
		if item != &"accent":
			check(probe.get_theme_color(item, Tokens.TYPE) == Tokens.COLORS[item], "Omitted color falls back: " + item)
	for item in Tokens.CONSTANTS:
		if item != &"space_1":
			check(probe.get_theme_constant(item, Tokens.TYPE) == Tokens.CONSTANTS[item], "Omitted constant falls back: " + item)
	for item in Tokens.FONT_SIZES:
		check(probe.get_theme_font_size(item, Tokens.TYPE) == Tokens.FONT_SIZES[item], "Omitted font size falls back: " + item)
	for item in Tokens.FONTS:
		check(probe.get_theme_font(item, Tokens.TYPE) == NEUTRAL.get_font(item, Tokens.TYPE), "Omitted font falls back: " + item)
	host.free()
