@tool
extends "res://rookframe/ui/components/data/paginated_content.gd"
const PresentationStyle = preload("res://rookframe/ui/themes/silkbound-ledger/presentation/paginated_content.gd")
var _skin = PresentationStyle.new()

func _style_pager() -> void:
	_skin._style_pager(self)

func _draw() -> void:
	_skin._draw(self)
