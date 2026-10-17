@tool
extends "res://rookframe/ui/components/surfaces/action_panel/action_leaf.gd"
const PresentationStyle = preload("res://rookframe/ui/themes/silkbound-ledger/presentation/action_leaf.gd")
var _skin = PresentationStyle.new()

func _refresh() -> void:
	_skin._refresh(self)

func get_surface_style() -> StyleBox:
	return _skin.get_surface_style(self)
