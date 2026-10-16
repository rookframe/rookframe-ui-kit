@tool
extends "res://rookframe/ui/components/surfaces/action_panel/connectors.gd"

func _draw() -> void:
	var panel := get_parent()
	if not panel.is_node_ready():
		return
	var leaves: Array[Control] = panel.linked_leaves()
	var motion := panel.get_node("DropMotion")
	var strap_width := 15.0 if panel.compact else 20.0
	for i in range(1, leaves.size()):
		if not Engine.is_editor_hint() and motion.active and not motion.connector_visible(i): continue
		var previous := leaves[i - 1].get_global_rect()
		var following := leaves[i].get_global_rect()
		var left := maxf(previous.position.x, following.position.x) + 5
		var right := minf(previous.end.x, following.end.x) - strap_width - 7
		var top := previous.end.y - 7
		var height := maxf(16, following.position.y - top + 6)
		for x in [left, right]:
			if not Engine.is_editor_hint() and motion.active:
				var a := Vector2(x, top) - global_position
				var b: Vector2 = motion.attachment(i, Vector2(x - following.position.x, 6))
				var c: Vector2 = motion.attachment(i, Vector2(x - following.position.x + strap_width, 6))
				draw_polygon(PackedVector2Array([a, a + Vector2(strap_width, 0), c, b]), PackedColorArray([Color.WHITE]), PackedVector2Array([Vector2.ZERO, Vector2(1,0), Vector2.ONE, Vector2(0,1)]), STRAP)
			else:
				draw_texture_rect(STRAP, Rect2(Vector2(x, top) - global_position, Vector2(strap_width, height)), false)

const STRAP = preload("res://rookframe/ui/assets/action-panel/connector.tres")
