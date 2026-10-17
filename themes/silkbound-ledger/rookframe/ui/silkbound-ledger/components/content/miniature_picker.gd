@tool
extends "res://rookframe/ui/components/content/miniature_picker.gd"
const PresentationStyle = preload("res://rookframe/ui/themes/silkbound-ledger/presentation/miniature_picker.gd")
var _skin = PresentationStyle.new()

func _arrange() -> void:
	_skin._arrange(self)
