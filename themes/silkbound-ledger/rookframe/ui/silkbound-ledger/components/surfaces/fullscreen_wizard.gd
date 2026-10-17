@tool
extends "res://rookframe/ui/components/surfaces/fullscreen_wizard.gd"
const PresentationStyle = preload("res://rookframe/ui/themes/silkbound-ledger/presentation/fullscreen_wizard.gd")
var _skin = PresentationStyle.new()

func _fit() -> void:
	_skin._fit(self)

func _fit_primary() -> void:
	_skin._fit_primary(self)

func _draw() -> void:
	_skin._draw(self)

func _label_line_height(label: Control, multiplier: float) -> void:
	_skin._label_line_height(self, label, multiplier)

func _style_step(step: Control, number: int, index: int) -> void:
	_skin._style_step(self, step, number, index)

func _style_primary_state(button: Button) -> void:
	_skin._style_primary_state(self, button)
