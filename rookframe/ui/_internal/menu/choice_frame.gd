@tool
extends StyleBox
## A height-scaled nine-patch keeps the cast end fittings proportional.
@export var texture: Texture2D
@export var finial: Texture2D
@export var tint := Color.WHITE
@export var source_margin := Vector2(260, 40)
@export var finial_fraction := Vector2(0.34, 0.25)
@export var depth := 3.0
@export var pressed_offset := 0.0


func _draw(canvas: RID, rect: Rect2) -> void:
	if texture == null:
		return
	var face := rect
	face.size.y -= depth
	face.position.y += pressed_offset
	var tip := face.size.y * finial_fraction
	if finial:
		finial.draw_rect(canvas, Rect2(face.position + Vector2(0, (face.size.y - tip.y) / 2), tip), false, tint)
		finial.draw_rect(canvas, Rect2(face.position + Vector2(face.size.x - tip.x, (face.size.y - tip.y) / 2), Vector2(-tip.x, tip.y)), false, tint)
	face.position.x += tip.x * 0.45
	face.size.x -= tip.x * 0.9
	var source_size := texture.get_size()
	var border := source_margin * face.size.y / source_size.y
	border.x = minf(border.x, face.size.x / 2)
	var sx := [0.0, source_margin.x, source_size.x - source_margin.x, source_size.x]
	var sy := [0.0, source_margin.y, source_size.y - source_margin.y, source_size.y]
	var dx := [0.0, border.x, face.size.x - border.x, face.size.x]
	var dy := [0.0, border.y, face.size.y - border.y, face.size.y]
	for y in range(3):
		for x in range(3):
			var target := Rect2(face.position + Vector2(dx[x], dy[y]), Vector2(dx[x + 1] - dx[x], dy[y + 1] - dy[y]))
			var source := Rect2(Vector2(sx[x], sy[y]), Vector2(sx[x + 1] - sx[x], sy[y + 1] - sy[y]))
			texture.draw_rect_region(canvas, target, source, tint)
