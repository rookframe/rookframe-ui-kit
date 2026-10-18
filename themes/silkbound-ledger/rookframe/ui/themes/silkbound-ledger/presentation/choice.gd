@tool
extends RefCounted
const Appearance = preload("res://rookframe/ui/_internal/presentation/appearance.gd")
const TEMPLATES = [
	preload("res://rookframe/ui/themes/silkbound-ledger/presentation/choice/row.tscn"),
	preload("res://rookframe/ui/themes/silkbound-ledger/presentation/choice/card.tscn"),
	preload("res://rookframe/ui/themes/silkbound-ledger/presentation/choice/marked_row.tscn"),
	preload("res://rookframe/ui/themes/silkbound-ledger/presentation/choice/marked_card.tscn"),
	preload("res://rookframe/ui/themes/silkbound-ledger/presentation/choice/list.tscn"),
]

func _style_choice(control) -> void:
	Appearance.apply_template(control, TEMPLATES[control.variant])
