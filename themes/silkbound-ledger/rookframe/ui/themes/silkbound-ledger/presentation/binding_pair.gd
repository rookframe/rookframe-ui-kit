@tool
extends RefCounted
const Appearance = preload("res://rookframe/ui/_internal/presentation/appearance.gd")




func _draw(control) -> void:
	var style = StyleBoxFlat.new()
	Appearance.write(style, ^"bg_color", Color("202521"))
	Appearance.write(style, ^"border_color", Color("66523d"))
	style.set_border_width_all(1)
	style.set_corner_radius_all(2)
	Appearance.write(style, ^"shadow_color", Color(0, 0, 0, 0.65))
	Appearance.write(style, ^"shadow_size", 2)
	for y in [0.0, maxf(0, control.size.y-14)]:
		var rect = Rect2(0, y, control.size.x, 14)
		control.draw_style_box(style, rect)
		for x in [6.0, control.size.x-6]:
			control.draw_circle(Vector2(x,y+7),2,Color("b99a69"))
