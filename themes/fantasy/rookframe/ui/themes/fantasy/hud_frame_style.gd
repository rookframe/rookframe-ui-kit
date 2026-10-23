@tool
extends StyleBox
## The walnut-and-brass casing at a fixed rim width, for HUD panels and plates.
## An optional brass bridge below the casing joins an attached panel to its bar.
## Content margins are the native StyleBox margins; nothing else is laid out here.
@export var texture: Texture2D
## Rim of `texture` in source pixels; it is drawn `rim` pixels wide.
@export var source_margin := 140.0
@export var rim := 12.0
@export var tint := Color.WHITE
@export var shadow_color := Color(0, 0, 0, 0.6)
@export var shadow_size := 0
@export var shadow_offset := Vector2.ZERO
## Height kept below the casing for the bridge, inside this style's rect.
@export var bridge_height := 0.0
## How far the bridge continues beyond the rect, under the panel below.
@export var bridge_overlap := 0.0
@export var bridge_width := 0.0
@export var bridge_rim := 5.0
@export var pressed_offset := 0.0
var _shadow: StyleBoxFlat


func _draw(canvas: RID, rect: Rect2) -> void:
	if texture == null:
		return
	var face := rect
	face.size.y -= bridge_height
	face.position.y += pressed_offset
	if bridge_width > 0:
		var bridge := Rect2(face.get_center().x - bridge_width / 2, face.end.y - rim * 2, bridge_width, rect.end.y - face.end.y + rim * 2 + bridge_overlap)
		_casing(canvas, bridge, bridge_rim, tint.darkened(0.15))
	if shadow_size > 0:
		if _shadow == null:
			_shadow = StyleBoxFlat.new()
		_shadow.bg_color = shadow_color
		_shadow.shadow_color = shadow_color
		_shadow.shadow_size = shadow_size
		_shadow.shadow_offset = shadow_offset
		_shadow.set_corner_radius_all(roundi(rim * 0.8))
		_shadow.draw(canvas, face.grow(-rim * 0.25))
	_casing(canvas, face, rim, tint)


func _casing(canvas: RID, face: Rect2, width: float, modulation: Color) -> void:
	var source_size := texture.get_size()
	var border := Vector2(minf(width, face.size.x / 2), minf(width, face.size.y / 2))
	var sx := [0.0, source_margin, source_size.x - source_margin, source_size.x]
	var sy := [0.0, source_margin, source_size.y - source_margin, source_size.y]
	var dx := [0.0, border.x, face.size.x - border.x, face.size.x]
	var dy := [0.0, border.y, face.size.y - border.y, face.size.y]
	for y in range(3):
		for x in range(3):
			var target := Rect2(face.position + Vector2(dx[x], dy[y]), Vector2(dx[x + 1] - dx[x], dy[y + 1] - dy[y]))
			var source := Rect2(Vector2(sx[x], sy[y]), Vector2(sx[x + 1] - sx[x], sy[y + 1] - sy[y]))
			texture.draw_rect_region(canvas, target, source, modulation)


func _get_draw_rect(rect: Rect2) -> Rect2:
	var bounds := rect.grow_individual(0, 0, 0, bridge_overlap)
	if shadow_size > 0:
		bounds = bounds.merge(Rect2(rect.position + shadow_offset, rect.size).grow(shadow_size))
	return bounds
