@tool
extends Texture2D
## A native CheckBox icon assembled from the button's existing carved materials.
## Godot still owns indicator placement, RTL, selection and disabled state.
var cap: Texture2D
var mark: Texture2D
var dimensions: Vector2i
var tint := Color.WHITE
var mark_tint := Color.WHITE
var edge_tint := Color.WHITE
var shadow_tint := Color.WHITE
var depth: float
var shadow_drop: float
var inset: float
var selected := false

func _get_width() -> int:
	return dimensions.x

func _get_height() -> int:
	return dimensions.y

func _has_alpha() -> bool:
	return true

func _draw(canvas: RID, position: Vector2, modulate: Color, transpose: bool) -> void:
	_draw_rect(canvas, Rect2(position, Vector2(dimensions)), false, modulate, transpose)

func _draw_rect(canvas: RID, rect: Rect2, _tile: bool, modulate: Color, transpose: bool) -> void:
	var scale := rect.size / Vector2(dimensions)
	var face := Rect2(rect.position, Vector2(dimensions.x, dimensions.y - shadow_drop) * scale)
	cap.draw_rect(canvas, Rect2(face.position + Vector2(0, shadow_drop) * scale, face.size), false, shadow_tint * modulate, transpose)
	cap.draw_rect(canvas, Rect2(face.position + Vector2(0, depth) * scale, face.size), false, edge_tint * modulate, transpose)
	if selected:
		face.position.y += depth * scale.y
	cap.draw_rect(canvas, face, false, tint * modulate, transpose)
	if selected:
		var mark_rect := Rect2(face.position + Vector2.ONE * inset * scale, face.size - Vector2.ONE * inset * scale * 2)
		mark.draw_rect(canvas, mark_rect, false, mark_tint * modulate, transpose)
