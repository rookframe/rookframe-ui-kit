@tool
extends "res://rookframe/ui/components/surfaces/hinged_leaf/hinged_leaf.gd"
const PresentationStyle = preload("res://rookframe/ui/themes/silkbound-ledger/presentation/hinged_leaf.gd")
var _skin = PresentationStyle.new()

func _binding_tint(extension: float) -> Color:
	return _skin._binding_tint(self, extension)
