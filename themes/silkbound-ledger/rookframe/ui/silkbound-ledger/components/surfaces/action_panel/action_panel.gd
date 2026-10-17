@tool
extends "res://rookframe/ui/components/surfaces/action_panel/action_panel.gd"
const PresentationStyle = preload("res://rookframe/ui/themes/silkbound-ledger/presentation/action_panel.gd")
var _skin = PresentationStyle.new()

func _style_layout(header: MarginContainer) -> void:
	_skin._style_layout(self, header)
