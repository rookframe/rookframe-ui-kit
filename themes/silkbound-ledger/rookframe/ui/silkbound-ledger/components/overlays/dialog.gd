@tool
extends "res://rookframe/ui/components/overlays/dialog.gd"
const PresentationStyle = preload("res://rookframe/ui/themes/silkbound-ledger/presentation/dialog.gd")
var _skin = PresentationStyle.new()

func _style_panels() -> void:
	_skin._style_panels(self)

func _draw_confirmation_underline() -> void:
	_skin._draw_confirmation_underline(self)

func _scrim_color() -> Color:
	return _skin._scrim_color(self)

func _style_compact_layout(compact: bool) -> void:
	_skin._style_compact_layout(self, compact)
