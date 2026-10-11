@tool
extends StyleBox
## Composes native styles without baking text or interactive states into artwork.
@export var layers: Array[StyleBox] = []
@export var corner: StyleBox
@export var corner_size := Vector2.ZERO


func _draw(canvas: RID, rect: Rect2) -> void:
	for layer in layers:
		layer.draw(canvas, rect)
	if corner:
		for x in [rect.position.x, rect.end.x - corner_size.x]:
			corner.draw(canvas, Rect2(Vector2(x, rect.end.y - corner_size.y), corner_size))


func _get_draw_rect(rect: Rect2) -> Rect2:
	var bounds := rect
	for layer in layers:
		bounds = bounds.merge(layer.get_draw_rect(rect))
	return bounds
