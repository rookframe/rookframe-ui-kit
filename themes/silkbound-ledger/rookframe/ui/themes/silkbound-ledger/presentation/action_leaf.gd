@tool
extends RefCounted
const Appearance = preload("res://rookframe/ui/_internal/presentation/appearance.gd")


const STYLES = [
	preload("res://rookframe/ui/assets/action-panel/body.tres"),
	preload("res://rookframe/ui/assets/action-panel/header.tres"),
	preload("res://rookframe/ui/assets/action-panel/footer.tres"),
	preload("res://rookframe/ui/assets/action-panel/emblem.tres")
]

func _refresh(control) -> void:
	if not control.is_node_ready():
		return
	var skin: Panel = control.get_node("Skin/Surface")
	var style: StyleBoxTexture = STYLES[control.surface]
	var grain: TextureRect = control.get_node("Skin/Grain")
	Appearance.write(grain, ^"visible", control.tiled_body and control.surface == 0)
	if grain.visible:
		Appearance.write(grain, ^"texture", preload("res://rookframe/ui/assets/action-panel/grain.tres"))
		Appearance.write(grain, ^"position", Vector2(4, 4))
		Appearance.write(grain, ^"size", (control.size - Vector2(8, 8)) / .4)
		if control._tiled_style == null:
			Appearance.write(control, ^"_tiled_style", style.duplicate())
			Appearance.write(control._tiled_style, ^"draw_center", false)
		style = control._tiled_style
	Appearance.override_item(skin, "styles", "panel", style)
	Appearance.write(skin, ^"size", control.size / .4)

func get_surface_style(control) -> StyleBox:
	return STYLES[control.surface]
