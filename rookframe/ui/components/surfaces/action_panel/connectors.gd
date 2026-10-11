@tool
extends Node2D
## Decoration only: never intercept pointer input or contribute to minimum size.
const STRAP = preload("res://rookframe/ui/assets/action-panel/connector.tres")
func _draw() -> void:
	var panel := get_parent()
	if not panel.is_node_ready():
		return
	var leaves: Array[Control] = [panel.get_node("Header/Leaf")]
	for section in panel.get_sections_slot().get_children():
		if section is Control and section.is_visible_in_tree():
			leaves.append(section)
	if panel.show_footer:
		leaves.append(panel.get_node("Footer/Leaf"))
	var strap_width := 15.0 if panel.compact else 20.0
	for i in range(1, leaves.size()):
		var previous := leaves[i - 1].get_global_rect()
		var following := leaves[i].get_global_rect()
		var left := maxf(previous.position.x, following.position.x) + 5
		var right := minf(previous.end.x, following.end.x) - strap_width - 7
		var top := previous.end.y - 7
		var height := maxf(16, following.position.y - top + 6)
		for x in [left, right]:
			draw_texture_rect(STRAP, Rect2(Vector2(x, top) - global_position, Vector2(strap_width, height)), false)
