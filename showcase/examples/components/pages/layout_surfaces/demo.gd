extends RefCounted
## Small composition helpers shared by these showcase pages.
const SKIN := "res://rookframe/ui/silkbound-ledger/"

static func skin(page, path: String, parent: Node, properties: Dictionary = {}) -> Node:
	return page.scene(SKIN + path, parent, properties)

static func stack(parent: Node) -> VBoxContainer:
	var content := VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 12)
	parent.add_child(content)
	return content

static func editor(parent: Node, copy: String, accessible_name: String) -> LineEdit:
	var input := LineEdit.new()
	input.text = copy
	input.accessibility_name = accessible_name
	input.custom_minimum_size.y = 44
	input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(input)
	return input

static func region(parent: Node, height: float) -> Control:
	var result := Control.new()
	result.custom_minimum_size.y = height
	result.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(result)
	return result

static func inset(parent: Node, amount: int = 16) -> MarginContainer:
	var result := MarginContainer.new()
	for edge in ["left", "right", "top", "bottom"]:
		result.add_theme_constant_override("margin_" + edge, amount)
	parent.add_child(result)
	return result

static func panel(page, parent: Node, title: String, copy: String) -> Node:
	var frame = skin(page, "components/layout/section.tscn", parent, {"title": title})
	page.note(frame.get_body_slot(), copy)
	return frame

static func auxiliary(page, path: String, parent: Node, appearance: String, properties: Dictionary = {}) -> Node:
	var configured := properties.duplicate()
	configured.theme = load("res://rookframe/ui/menu/MenuTheme.tres" if appearance == "Fantasy" else "res://rookframe/ui/menu/cyberpunk/CyberpunkTheme.tres")
	return page.scene("res://rookframe/ui/" + path, parent, configured)
