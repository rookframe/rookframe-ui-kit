@tool
extends "res://rookframe/ui/components/overlays/file_picker_dialog.gd"
const PresentationStyle = preload("res://rookframe/ui/themes/silkbound-ledger/presentation/file_picker_dialog.gd")
var _skin = PresentationStyle.new()

func _style_spacing(compact: bool) -> void:
	_skin._style_spacing(self, compact)
