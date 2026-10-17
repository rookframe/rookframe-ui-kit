@tool
extends "res://rookframe/ui/components/surfaces/action_panel/connectors.gd"
const PresentationStyle = preload("res://rookframe/ui/themes/silkbound-ledger/presentation/connectors.gd")
var _skin = PresentationStyle.new()

func _draw() -> void:
	_skin._draw(self)
