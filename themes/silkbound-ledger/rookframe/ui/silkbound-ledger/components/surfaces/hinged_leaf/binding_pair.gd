@tool
extends "res://rookframe/ui/components/surfaces/hinged_leaf/binding_pair.gd"
const PresentationStyle = preload("res://rookframe/ui/themes/silkbound-ledger/presentation/binding_pair.gd")
var _skin = PresentationStyle.new()

func _draw() -> void:
	_skin._draw(self)
