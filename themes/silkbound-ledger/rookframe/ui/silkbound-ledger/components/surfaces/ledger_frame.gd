@tool
extends "res://rookframe/ui/components/surfaces/ledger_frame.gd"

func _draw_bindings() -> void:
	var previous := Rect2()
	for rect in _sections:
		if not rect.has_area():
			continue
		if previous.has_area():
			var top := previous.end.y - 6
			for x in [maxf(previous.position.x, rect.position.x) + 26, minf(previous.end.x, rect.end.x) - 48]:
				get_node("Bindings").draw_texture_rect(STRAP, Rect2(x, top, 16, maxf(16, rect.position.y - top + 6)), false)
		previous = rect

const STRAP = preload("res://rookframe/ui/assets/action-panel/connector.tres")
