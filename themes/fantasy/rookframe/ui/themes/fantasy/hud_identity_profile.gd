@tool
extends Theme
## HUD context profile for the identity slot: the plate reads at HUD scale and keeps
## the bar short enough for its carved tiles. Items only; the main Theme declares
## every variation's base.
const Materials = preload("res://rookframe/ui/menu/materials/menu_materials.gd")
const ITEMS = {
	"RookframeIdentity": "hud.identity.title.size",
	"RookframeMeta": "hud.identity.meta.size",
	"RookframeValue": "hud.identity.value.size",
}

func _init() -> void:
	for type in ITEMS:
		set_font_size("font_size", type, Materials.value(ITEMS[type]))
	# Copy lines and the vital stack tightly inside the plate.
	set_constant("separation", &"VBoxContainer", Materials.value("hud.identity.gap"))
