extends RefCounted
## Semantic references only. Both themes resolve the same editor vocabulary.
static var ELEMENTS: Dictionary = _elements()


static func _elements() -> Dictionary:
	var elements := {}
	for kind in ["tool", "action", "standard"]:
		for compact in [false, true]:
			var suffix := ".compact" if compact else ""
			var button := {
				"base_type": &"Button",
				"fonts/font": "editor.font",
				"font_sizes/font_size": "editor.font_size" + suffix,
				"constants/minimum_height": "editor.height" + suffix,
				"constants/icon_max_width": "editor.icon_size" + suffix,
				"constants/h_separation": "editor.icon_gap",
			}
			for state in ["normal", "hover", "pressed", "hover_pressed", "disabled", "focus"]:
				button["styles/" + state] = "editor." + kind + "." + state + suffix
				button["colors/icon_" + state + "_color"] = "editor." + kind + ".ink." + state
				button["colors/" + ("font_color" if state == "normal" else "font_" + state + "_color")] = "editor." + kind + ".ink." + state
			elements["editor.button." + kind + ("@compact" if compact else "")] = button
	for kind in ["rail", "panel", "inset", "log"]:
		for compact in [false, true]:
			elements["editor.surface." + kind + ("@compact" if compact else "")] = {
				"base_type": &"PanelContainer",
				"styles/panel": "editor.surface." + kind + (".compact" if compact else ""),
			}
	for kind in ["heading", "body", "meta", "accent"]:
		for compact in [false, true]:
			elements["editor." + kind + ("@compact" if compact else "")] = {
				"base_type": &"Label",
				"fonts/font": "type.ui" if kind == "meta" else "editor.font",
				"font_sizes/font_size": "editor." + kind + ".size" + (".compact" if compact else ""),
				"colors/font_color": "editor." + kind + ".ink",
			}
	elements["editor.tool.stack"] = {"base_type": &"BoxContainer", "constants/separation": "editor.tool_gap"}
	elements["editor.divider"] = {"base_type": &"HSeparator", "styles/separator": "editor.rule", "constants/separation": "editor.rule_gap"}
	return elements
