@tool
extends "res://rookframe/ui/menu/menu_theme.gd"
## Fantasy materials are optional; shared controls and compilation live in UI Kit.
const Mapping = preload("menu_theme_map.gd")
const Materials = preload("materials/menu_materials.gd")

func _init() -> void:
	var extensions: Array[Script] = preload("res://rookframe/ui/menu/shell_theme_maps.gd").MAPS.duplicate()
	extensions.append(preload("expansion_theme_map.gd"))
	extensions.append(preload("../themes/fantasy/checkbox_theme_map.gd"))
	extensions.append(preload("../themes/fantasy/hud_theme_map.gd"))
	super(Mapping, Materials, extensions)
