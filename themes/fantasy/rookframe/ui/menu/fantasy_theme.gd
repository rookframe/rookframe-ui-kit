@tool
extends "res://rookframe/ui/menu/menu_theme.gd"
## Fantasy materials are optional; shared controls and compilation live in UI Kit.
const Mapping = preload("menu_theme_map.gd")
const Materials = preload("materials/menu_materials.gd")

func _init() -> void:
	super(Mapping, Materials)
