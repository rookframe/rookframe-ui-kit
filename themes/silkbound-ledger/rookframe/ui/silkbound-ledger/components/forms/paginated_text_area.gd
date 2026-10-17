@tool
extends "res://rookframe/ui/components/forms/paginated_text_area.gd"
const PresentationStyle = preload("res://rookframe/ui/themes/silkbound-ledger/presentation/paginated_text_area.gd")
var _skin = PresentationStyle.new()

func _style_editor() -> void:
	_skin._style_editor(self)
