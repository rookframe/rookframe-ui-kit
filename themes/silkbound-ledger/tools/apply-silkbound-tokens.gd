extends SceneTree
## Writes Silkbound Ledger token values into every authored value that names a token.
##
## `rookframe/ui/theme/silkbound_tokens.gd` holds the values. A Theme, StyleBox or
## scene node names the token behind each of its own properties in
## `metadata/tokens`: `{"bg_color": &"surface", "border_color": [&"ornament", 0.38]}`.
## A Theme names its items by path (`"RookframeMeta/colors/font_color"`). An array
## keeps the token's color with its own alpha. Font items take the token's font
## resource; font sizes and constants take the token's number.
##
## Run from the repository root after `python3 tools/workspace.py prepare`, which
## installs the fonts these values reference:
##   godot --headless --path showcase --script "$PWD/themes/silkbound-ledger/tools/apply-silkbound-tokens.gd"
## Add `-- --check` to report drift without writing; it exits 1 if any value differs.

const HEADER := "^\\[(gd_resource|gd_scene|ext_resource|sub_resource|resource|node|connection|editable)\\b"
const META := "metadata/tokens = "

var tokens: GDScript
var check := false
var failures: PackedStringArray = []
var changed: PackedStringArray = []
## External resources a file needs, by path, added after its blocks are rewritten.
var pending: Dictionary[String, String] = {}

func _initialize() -> void:
	check = OS.get_cmdline_user_args().has("--check")
	var package := (get_script() as Script).resource_path.get_base_dir().get_base_dir()
	tokens = load(package.path_join("rookframe/ui/theme/silkbound_tokens.gd"))
	for path in _sources(package.path_join("rookframe/ui")):
		_apply(path)
	for failure in failures:
		push_error(failure)
	var verb := "differ" if check else "updated"
	print("SILKBOUND_TOKENS: %d files %s; %d failures" % [changed.size(), verb, failures.size()])
	for path in changed:
		print("  ", path)
	quit(1 if not failures.is_empty() or (check and not changed.is_empty()) else 0)

func _sources(folder: String) -> PackedStringArray:
	var result := PackedStringArray()
	for directory in DirAccess.get_directories_at(folder):
		result.append_array(_sources(folder.path_join(directory)))
	for file in DirAccess.get_files_at(folder):
		if file.get_extension() in ["tres", "tscn"]:
			var path := folder.path_join(file)
			if FileAccess.get_file_as_string(path).contains(META):
				result.append(path)
	return result

func _apply(path: String) -> void:
	var source := FileAccess.get_file_as_string(path)
	var lines: Array[String] = []
	lines.assign(source.split("\n"))
	pending.clear()
	var header := RegEx.create_from_string(HEADER)
	var start := 0
	var index := 0
	# Blocks are rewritten from the bottom up so earlier indices stay valid.
	var blocks: Array[Vector2i] = []
	while index <= lines.size():
		if index == lines.size() or header.search(lines[index]) != null:
			if index > start:
				blocks.append(Vector2i(start, index))
			start = index
		index += 1
	blocks.reverse()
	for block in blocks:
		_apply_block(path, lines, block.x, block.y)
	var last := -1
	for line in lines.size():
		if lines[line].begins_with("[ext_resource "):
			last = line
	for resource_path in pending:
		last += 1
		var type := ResourceLoader.load(resource_path).get_class()
		lines.insert(last, '[ext_resource type="%s" path="%s" id="%s"]' % [type, resource_path, pending[resource_path]])
	var result := "\n".join(lines)
	if result == source:
		return
	changed.append(path)
	if not check:
		var file := FileAccess.open(path, FileAccess.WRITE)
		file.store_string(result)

func _apply_block(path: String, lines: Array[String], start: int, end: int) -> void:
	var meta := -1
	for index in range(start, end):
		if lines[index].begins_with(META):
			meta = index
	if meta < 0:
		return
	var text := lines[meta].trim_prefix(META)
	var last := meta
	while text.count("{") != text.count("}") and last + 1 < end:
		last += 1
		text += "\n" + lines[last]
	var bindings: Variant = str_to_var(text)
	if not bindings is Dictionary:
		failures.append("%s:%d: metadata/tokens is not a Dictionary" % [path, meta + 1])
		return
	for property in bindings:
		var value := _literal(path, lines, String(property), bindings[property])
		if value.is_empty():
			continue
		var line := String(property) + " = " + value
		var found := false
		for index in range(start, meta):
			if lines[index].begins_with(String(property) + " = "):
				lines[index] = line
				found = true
		if not found:
			lines.insert(meta, line)
			meta += 1

## The serialized value a binding produces, or "" after recording a failure.
func _literal(path: String, lines: Array[String], property: String, binding: Variant) -> String:
	var token: StringName = binding[0] if binding is Array else binding
	if property.contains("/fonts/") or property.begins_with("theme_override_fonts/"):
		if not tokens.FONTS.has(token):
			failures.append("%s: %s names unknown font token %s" % [path, property, token])
			return ""
		return 'ExtResource("%s")' % _font_resource(lines, tokens.FONTS[token])
	if property.contains("font_size"):
		if not tokens.FONT_SIZES.has(token):
			failures.append("%s: %s names unknown font size token %s" % [path, property, token])
			return ""
		return var_to_str(tokens.FONT_SIZES[token])
	if property.contains("/constants/") or property.begins_with("theme_override_constants/"):
		if not tokens.CONSTANTS.has(token):
			failures.append("%s: %s names unknown constant token %s" % [path, property, token])
			return ""
		return var_to_str(tokens.CONSTANTS[token])
	if not tokens.COLORS.has(token) and not tokens.PRIMITIVES.has(token):
		failures.append("%s: %s names unknown color %s" % [path, property, token])
		return ""
	var color: Color = tokens.color(token)
	if binding is Array:
		color.a = binding[1]
	return "Color(%s, %s, %s, %s)" % [_number(color.r), _number(color.g), _number(color.b), _number(color.a)]

## Six decimals without trailing zeros, as the authored resources already write colors.
func _number(value: float) -> String:
	var text := "%.6f" % value
	text = text.rstrip("0")
	return text.trim_suffix(".")

## The id of the file's external resource for `resource_path`; absent ones are added later.
func _font_resource(lines: Array[String], resource_path: String) -> String:
	var id_pattern := RegEx.create_from_string('id="([^"]+)"')
	for line in lines:
		if line.begins_with("[ext_resource ") and line.contains('path="%s"' % resource_path):
			return id_pattern.search(line).get_string(1)
	if not pending.has(resource_path):
		pending[resource_path] = "token_" + resource_path.get_file().get_basename()
	return pending[resource_path]
