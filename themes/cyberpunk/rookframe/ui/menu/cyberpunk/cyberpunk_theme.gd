@tool
extends "../menu_theme.gd"
## Neon Circuit: a second native Theme for the Main Menu and Settings.
const CyberpunkMapping = preload("cyberpunk_theme_map.gd")
const CyberpunkMaterials = preload("materials/cyberpunk_materials.gd")

func _init() -> void:
	var extensions: Array[Script] = preload("res://rookframe/ui/menu/shell_theme_maps.gd").MAPS.duplicate()
	extensions.append(preload("expansion_theme_map.gd"))
	extensions.append(preload("hud_theme_map.gd"))
	super(CyberpunkMapping, CyberpunkMaterials, extensions)
