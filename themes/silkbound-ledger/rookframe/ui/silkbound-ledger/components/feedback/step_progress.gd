@tool
extends "res://rookframe/ui/components/feedback/step_progress.gd"
const PresentationStyle = preload("res://rookframe/ui/themes/silkbound-ledger/presentation/step_progress.gd")
var _skin = PresentationStyle.new()

func _style_number(number: Label) -> void:
	_skin._style_number(self, number)

func _style_cell(cell: VBoxContainer) -> void:
	_skin._style_cell(self, cell)

func _style_rail(rail: HBoxContainer) -> void:
	_skin._style_rail(self, rail)

func _step_icon_color() -> Color:
	return _skin._step_icon_color(self)

func _step_number_color(state_name: String) -> Color:
	return _skin._step_number_color(self, state_name)

func _connector_color(complete: bool) -> Color:
	return _skin._connector_color(self, complete)
