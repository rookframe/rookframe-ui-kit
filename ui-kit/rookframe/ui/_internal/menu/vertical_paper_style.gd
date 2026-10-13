@tool
extends StyleBox
## Fixed end caps and mirrored paper repeats, drawn from one unmodified texture.
@export var texture: Texture2D
@export var region := Rect2()
@export var side_width := 0.0
@export var cap_height := 0.0
@export var transition_height := 0.0
@export var blend_height := 0.0


func _draw(canvas: RID, rect: Rect2) -> void:
	if texture == null or rect.size.x <= 0.0 or rect.size.y <= 0.0:
		return
	var cap := minf(cap_height, rect.size.y / 2.0)
	var cap_top := region.position.y + cap_height
	var cap_bottom := region.end.y - cap_height
	# Keep the shaded paper beside each roll out of the repeated reading field.
	var paper_top := cap_top + transition_height
	var paper_bottom := cap_bottom - transition_height
	var repeat_height := paper_bottom - paper_top
	if repeat_height <= 0.0:
		return
	_strip(canvas, Rect2(rect.position, Vector2(rect.size.x, cap)), region.position.y, cap_top)
	var transition := minf(transition_height, (rect.size.y - cap * 2.0) / 2.0)
	var y := rect.position.y + cap
	if transition > 0.0:
		_strip(canvas, Rect2(Vector2(rect.position.x, y), Vector2(rect.size.x, transition)), cap_top, paper_top)
		y += transition
	var remaining := rect.size.y - (cap + transition) * 2.0
	var mirrored := false
	while remaining > 0.0:
		var height := minf(remaining, repeat_height)
		# Reflection joins identical source rows and keeps grain and wear at 1:1 height.
		var source_top := paper_bottom if mirrored else paper_top
		var source_bottom := source_top + (-height if mirrored else height)
		_strip(canvas, Rect2(Vector2(rect.position.x, y), Vector2(rect.size.x, height)), source_top, source_bottom)
		y += height
		remaining -= height
		mirrored = not mirrored
	# The last repeat can end at any phase. Blend into the original paper directly
	# above the bottom cap so its shadow always meets the same source pixels.
	var blend := minf(blend_height, rect.size.y - (cap + transition) * 2.0)
	if blend > 0.0:
		_strip(canvas, Rect2(Vector2(rect.position.x, y - blend), Vector2(rect.size.x, blend)), paper_bottom - blend, paper_bottom, 0.0)
	if transition > 0.0:
		_strip(canvas, Rect2(Vector2(rect.position.x, y), Vector2(rect.size.x, transition)), paper_bottom, cap_bottom)
		y += transition
	_strip(canvas, Rect2(Vector2(rect.position.x, y), Vector2(rect.size.x, cap)), cap_bottom, region.end.y)


func _strip(canvas: RID, rect: Rect2, source_top: float, source_bottom: float, top_alpha := 1.0) -> void:
	var side := minf(side_width, rect.size.x / 2.0)
	var x := [rect.position.x, rect.position.x + side, rect.end.x - side, rect.end.x]
	var u := [region.position.x, region.position.x + side_width, region.end.x - side_width, region.end.x]
	var texture_size := texture.get_size()
	var colors := PackedColorArray([Color(1, 1, 1, top_alpha), Color(1, 1, 1, top_alpha), Color.WHITE, Color.WHITE])
	for column in range(3):
		if x[column + 1] <= x[column]:
			continue
		var points := PackedVector2Array([
			Vector2(x[column], rect.position.y), Vector2(x[column + 1], rect.position.y),
			Vector2(x[column + 1], rect.end.y), Vector2(x[column], rect.end.y),
		])
		var uv := PackedVector2Array([
			Vector2(u[column], source_top) / texture_size, Vector2(u[column + 1], source_top) / texture_size,
			Vector2(u[column + 1], source_bottom) / texture_size, Vector2(u[column], source_bottom) / texture_size,
		])
		RenderingServer.canvas_item_add_polygon(canvas, points, colors, uv, texture.get_rid())
