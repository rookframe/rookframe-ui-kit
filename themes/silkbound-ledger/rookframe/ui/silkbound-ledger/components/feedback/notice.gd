@tool
extends "res://rookframe/ui/components/feedback/notice.gd"
const PresentationStyle = preload("res://rookframe/ui/themes/silkbound-ledger/presentation/notice.gd")
var _skin = PresentationStyle.new()

func _tone_color() -> Color:
	return _skin._tone_color(self)
