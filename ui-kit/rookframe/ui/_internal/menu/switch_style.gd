@tool
extends StyleBox
## Native selection stays independent of hover, press, focus and availability.
@export var unselected: StyleBox
@export var selected: StyleBox
@export var selected_rtl: StyleBox


func _draw(canvas: RID, rect: Rect2) -> void:
	var button := get_current_item_drawn() as BaseButton
	var face := unselected
	if button and button.button_pressed:
		face = selected_rtl if button.is_layout_rtl() else selected
	face.draw(canvas, rect)
