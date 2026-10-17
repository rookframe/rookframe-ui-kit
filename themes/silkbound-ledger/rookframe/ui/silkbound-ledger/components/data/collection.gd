@tool
extends "res://rookframe/ui/components/data/collection.gd"
const PresentationStyle = preload("res://rookframe/ui/themes/silkbound-ledger/presentation/collection.gd")
var _skin = PresentationStyle.new()

func _draw() -> void:
	_skin._draw(self)

func _style_action(action: Button) -> void:
	_skin._style_action(self, action)

func _style_collection(phone: bool, tablet: bool) -> void:
	_skin._style_collection(self, phone, tablet)

func _style_record(title: Label, subtitle: Label, value: Label, phone: bool, tablet: bool, inventory: bool, entry: Dictionary) -> void:
	_skin._style_record(self, title, subtitle, value, phone, tablet, inventory, entry)

func _style_action_type(action: Button, phone: bool, tablet: bool) -> void:
	_skin._style_action_type(self, action, phone, tablet)

func _style_grid(grid: GridContainer, phone: bool, tablet: bool) -> void:
	_skin._style_grid(self, grid, phone, tablet)

func _style_record_spacing(row: Control, row_inset: MarginContainer, phone: bool, tablet: bool, inventory: bool) -> void:
	_skin._style_record_spacing(self, row, row_inset, phone, tablet, inventory)
