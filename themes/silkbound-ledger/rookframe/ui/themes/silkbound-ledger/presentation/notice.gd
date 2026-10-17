@tool
extends RefCounted
const Appearance = preload("res://rookframe/ui/_internal/presentation/appearance.gd")

const TONE_COLORS := [
	Color("d0be8e"), Color("d0be8e"), Color("a9c4b6"), Color("ff817a"),
]




func _tone_color(control) -> Color:
	return TONE_COLORS[control.tone]
