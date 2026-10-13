extends Control
## Two stationary, riveted leather tabs. The bounds span the joined edges.
func _ready() -> void:
	resized.connect(queue_redraw)
func _draw() -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("202521")
	style.border_color = Color("66523d")
	style.set_border_width_all(1)
	style.set_corner_radius_all(2)
	style.shadow_color = Color(0, 0, 0, 0.65)
	style.shadow_size = 2
	for y in [0.0, maxf(0, size.y-14)]:
		var rect := Rect2(0, y, size.x, 14)
		draw_style_box(style, rect)
		for x in [6.0, size.x-6]:
			draw_circle(Vector2(x,y+7),2,Color("b99a69"))
