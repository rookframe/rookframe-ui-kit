@tool
extends "res://rookframe/ui/components/forms/task_text_field.gd"
const PresentationStyle = preload("res://rookframe/ui/themes/silkbound-ledger/presentation/task_text_field.gd")
var _skin = PresentationStyle.new()

func _style_field() -> void:
	_skin._style_field(self)
