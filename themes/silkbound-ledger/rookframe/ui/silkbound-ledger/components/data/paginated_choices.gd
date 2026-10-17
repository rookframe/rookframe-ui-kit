@tool
extends "res://rookframe/ui/components/data/paginated_choices.gd"
const PresentationStyle = preload("res://rookframe/ui/themes/silkbound-ledger/presentation/paginated_choices.gd")
var _skin = PresentationStyle.new()

func _range_format() -> String:
	return _skin._range_format(self)

func _fit_presentation() -> int:
	return _skin._fit_presentation(self)

func _draw() -> void:
	_skin._draw(self)

func _arrange_rows() -> Vector3:
	return _skin._arrange_rows(self)

func _style_entry(row: Control, entry: Dictionary, selected_id: String) -> void:
	_skin._style_entry(self, row, entry, selected_id)
