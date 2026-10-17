extends VBoxContainer
## Shared specimen framing; component behavior stays in the production resources.

var entry: Dictionary = {}
var examples: Array[VBoxContainer] = []
var reduced_motion := false
var _preview_scopes: Array[Node] = []
# Explicit scopes isolate examples, popups and viewport content from the chrome.
var preview_theme: Theme = ThemeDB.get_default_theme():
	set(value):
		preview_theme = value
		for scope in _preview_scopes:
			if is_instance_valid(scope):
				scope.theme = value
var section_titles: Array[String] = []
var section_blocks: Array[Control] = []

func _ready() -> void:
	var paths := PackedStringArray()
	for resource in entry.get("covers", []):
		if resource.begins_with("res://"):
			paths.append(resource)
	var reference := RichTextLabel.new()
	reference.name = "UsageReference"
	reference.fit_content = true
	reference.scroll_active = false
	reference.selection_enabled = true
	reference.focus_mode = Control.FOCUS_ALL
	reference.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	reference.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	reference.text = "Resource path:\n" + "\n".join(paths)
	add_child(reference)

func section(title: String, description: String = "") -> VBoxContainer:
	var block := VBoxContainer.new()
	block.add_theme_constant_override("separation", 12)
	add_child(block)
	section_titles.append(title)
	section_blocks.append(block)
	var heading := label(title)
	heading.add_theme_font_size_override("font_size", 22)
	block.add_child(heading)
	if not description.is_empty():
		block.add_child(label(description))
	var frame := PanelContainer.new()
	frame.theme_type_variation = &"ShowcaseExample"
	block.add_child(frame)
	var body := VBoxContainer.new()
	body.add_theme_constant_override("separation", 14)
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	frame.add_child(body)
	bind_preview_theme(body)
	examples.append(body)
	return body

func label(copy: String) -> Label:
	var result: Label = preload("res://rookframe/ui/components/data/label.tscn").instantiate()
	result.text = copy
	result.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	result.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return result

func note(parent: Node, copy: String) -> Label:
	var result := label(copy)
	parent.add_child(result)
	return result

func button(parent: Node, copy: String, action: Callable = Callable()) -> Button:
	var result: Button = preload("res://rookframe/ui/components/actions/button.tscn").instantiate()
	result.text = copy
	result.compact = true
	result.accessibility_name = copy
	parent.add_child(result)
	if action.is_valid():
		result.pressed.connect(action)
	return result

func flow(parent: Node) -> HFlowContainer:
	var result := HFlowContainer.new()
	result.add_theme_constant_override("h_separation", 8)
	result.add_theme_constant_override("v_separation", 8)
	parent.add_child(result)
	return result

func scene(path: String, parent: Node, properties: Dictionary = {}) -> Node:
	var result: Node = load(path).instantiate()
	# Page-owned overlays sit outside the themed example bodies.
	if parent == self and (result is Control or result is Window):
		bind_preview_theme(result)
	for key in properties:
		result.set(key, properties[key])
	parent.add_child(result)
	return result

func bind_preview_theme(node: Node) -> void:
	node.theme = preview_theme
	_preview_scopes.append(node)
