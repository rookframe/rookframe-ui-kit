@tool
extends "res://rookframe/ui/components/surfaces/ledger_frame.gd"
const PresentationStyle = preload("res://rookframe/ui/themes/silkbound-ledger/presentation/ledger_frame.gd")
var _skin = PresentationStyle.new()

func _draw_bindings() -> void:
	_skin._draw_bindings(self)
