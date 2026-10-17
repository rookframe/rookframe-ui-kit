@tool
extends "res://rookframe/ui/components/data/summary_block.gd"
const PresentationStyle = preload("res://rookframe/ui/themes/silkbound-ledger/presentation/summary_block.gd")
var _skin = PresentationStyle.new()

func _fit_presentation() -> void:
	_skin._fit_presentation(self)
