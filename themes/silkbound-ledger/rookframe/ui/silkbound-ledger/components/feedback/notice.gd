@tool
extends "res://rookframe/ui/components/feedback/notice.gd"

const TONE_COLORS := [
	Color("d0be8e"), Color("d0be8e"), Color("a9c4b6"), Color("ff817a"),
]

func _tone_color() -> Color:
	return TONE_COLORS[tone]
