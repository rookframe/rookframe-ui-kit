extends RefCounted
## Shared native focus policy, without owning selection or actions.
static func eligible(control: Variant) -> bool:
	if not is_instance_valid(control) or not control.is_inside_tree() or not control.is_visible_in_tree(): return false
	var mode: int = control.get_focus_mode_with_override()
	if mode == Control.FOCUS_NONE or (mode == Control.FOCUS_ACCESSIBILITY and not control.get_tree().is_accessibility_enabled()): return false
	return not (control is BaseButton and control.disabled)

static func first(node: Node) -> Control:
	if node is Control and eligible(node):
		return node
	for child in node.get_children():
		var result := first(child)
		if result != null:
			return result
	return null

static func give(control: Variant) -> bool:
	if not eligible(control):
		return false
	control.grab_focus()
	var parent: Node = control.get_parent()
	while parent != null:
		if parent is ScrollContainer:
			parent.ensure_control_visible(control)
			break
		parent = parent.get_parent()
	return control.has_focus()

static func restore(ordered: Array, position: int, fallback: Control = null) -> bool:
	for index in range(maxi(0, position), ordered.size()):
		if give(first(ordered[index])): return true
	for index in range(mini(position - 1, ordered.size() - 1), -1, -1):
		if give(first(ordered[index])): return true
	return give(fallback)
