@tool
extends RefCounted
## Presentation-only writes are reversible; caller edits made later take priority.
static var _writers: Array[Node] = []

static func owning_theme(node: Node) -> Theme:
	var current := node
	while current != null:
		if (current is Control or current is Window) and current.theme != null:
			if not current.has_meta(&"_presentation_theme") or current.theme != current.get_meta(&"_presentation_theme"):
				return current.theme
		current = current.get_parent()
	return null

static func hooks(node: Node) -> RefCounted:
	var theme := owning_theme(node)
	var cached: Array = node.get_meta(&"_presentation_hooks", [])
	if not cached.is_empty() and cached[0] == theme:
		return cached[1]
	var script: Script = node.get_script()
	var implementation: RefCounted
	if theme != null and theme.get("presentation_hooks") != null:
		while script != null:
			var hook_script: Script = theme.presentation_hooks.get(script.resource_path)
			if hook_script != null:
				implementation = hook_script.new()
				break
			script = script.get_base_script()
	if not cached.is_empty():
		restore(node)
	node.set_meta(&"_presentation_hooks", [theme, implementation])
	return implementation

static func has_hook(node: Node, method: StringName) -> bool:
	var implementation := hooks(node)
	return implementation != null and implementation.has_method(method)

static func invoke(node: Node, method: StringName, args: Array = []) -> Variant:
	var implementation := hooks(node)
	_writers.append(node)
	var result: Variant = implementation.callv(method, [node] + args)
	_writers.pop_back()
	return result

static func write(target: Object, property: NodePath, value: Variant) -> void:
	if target is Node and not _writers.is_empty():
		var writer: Node = _writers.back()
		var journal: Dictionary = writer.get_meta(&"_presentation_values", {})
		var key := str(target.get_instance_id()) + ":" + String(property)
		if not journal.has(key):
			journal[key] = [weakref(target), property, target.get_indexed(property), value]
		else:
			journal[key][3] = value
		writer.set_meta(&"_presentation_values", journal)
	target.set_indexed(property, value)

static func override_item(target: Control, kind: String, item: StringName, value: Variant) -> void:
	write(target, NodePath("theme_override_" + kind + "/" + String(item)), value)

static func restore(writer: Node) -> void:
	var journal: Dictionary = writer.get_meta(&"_presentation_values", {})
	for entry in journal.values():
		var target: Object = entry[0].get_ref()
		if target != null and target.get_indexed(entry[1]) == entry[3]:
			target.set_indexed(entry[1], entry[2])
	writer.remove_meta(&"_presentation_values")

static func apply_template(writer: Node, template: PackedScene) -> void:
	_writers.append(writer)
	var state := template.get_state()
	for index in state.get_node_count():
		var target := writer.get_node_or_null(state.get_node_path(index))
		if target == null:
			continue
		for item in state.get_node_property_count(index):
			var property := state.get_node_property_name(index, item)
			if property == &"script":
				continue
			var value: Variant = state.get_node_property_value(index, item)
			if property == &"theme":
				# Keep an explicitly assigned canonical resource visible in the Inspector.
				# Scope its component-native profile to the existing content branches.
				if target.get("theme") == owning_theme(target) and target.get("theme") != null:
					target.set_meta(&"_presentation_child_theme", value)
					for child in target.get_children():
						profile_child(target, child)
					continue
				target.set_meta(&"_presentation_theme", value)
			# Runtime-created children use the same public core scene and inherit.
			if value is PackedScene:
				continue
			if String(property).begins_with("theme_override_") and target.get(property) != null:
				continue
			if value is Resource and value.resource_local_to_scene:
				value = value.duplicate(true)
			write(target, NodePath(property), value)
	_writers.pop_back()

static func profile_child(owner: Node, child: Node) -> void:
	if not owner.has_meta(&"_presentation_child_theme") or not (child is Control or child is Window):
		return
	if child.theme != null:
		return
	var profile: Theme = owner.get_meta(&"_presentation_child_theme")
	child.set_meta(&"_presentation_theme", profile)
	_writers.append(owner)
	write(child, ^"theme", profile)
	_writers.pop_back()
