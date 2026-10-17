@tool
extends "res://rookframe/ui/components/content/miniature_browser.gd"
const PresentationStyle = preload("res://rookframe/ui/themes/silkbound-ledger/presentation/miniature_browser.gd")
var _skin = PresentationStyle.new()

func _style_row(row: Button) -> void:
	_skin._style_row(self, row)
