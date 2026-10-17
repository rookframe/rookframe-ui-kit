@tool
extends "res://rookframe/ui/_internal/data/collection_row.gd"
const PresentationStyle = preload("res://rookframe/ui/themes/silkbound-ledger/presentation/collection_row.gd")
var _skin = PresentationStyle.new()

func _draw() -> void:
	_skin._draw(self)
