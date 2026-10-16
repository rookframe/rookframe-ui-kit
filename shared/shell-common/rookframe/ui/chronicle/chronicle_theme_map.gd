extends RefCounted
## A retained narrative record, shared by both current themes.
## Semantic references only; appearance belongs to each theme's materials.
static var ELEMENTS: Dictionary = _elements()


static func _elements() -> Dictionary:
	var elements := {}
	for compact in [false, true]:
		var usage_suffix := "@compact" if compact else ""
		var material_suffix := ".compact" if compact else ""
		elements["chronicle.surface" + usage_suffix] = {
			"base_type": &"PanelContainer",
			"styles/panel": "chronicle.surface" + material_suffix,
		}
		for kind in ["heading", "body", "meta"]:
			elements["chronicle." + kind + usage_suffix] = {
				"base_type": &"Label",
				"fonts/font": "chronicle." + kind + ".font",
				"font_sizes/font_size": "chronicle." + kind + ".size" + material_suffix,
				"colors/font_color": "chronicle." + kind + ".ink",
			}
		elements["chronicle.divider" + usage_suffix] = {
			"base_type": &"HSeparator",
			"styles/separator": "chronicle.rule",
			"constants/separation": "chronicle.rule_gap" + material_suffix,
		}
	return elements
