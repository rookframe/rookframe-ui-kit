@tool
extends "res://rookframe/ui/components/feedback/task_state.gd"
const PresentationStyle = preload("res://rookframe/ui/themes/silkbound-ledger/presentation/task_state.gd")
var _skin = PresentationStyle.new()

func _state_icon_color() -> Color:
	return _skin._state_icon_color(self)
