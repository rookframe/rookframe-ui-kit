extends RefCounted
## Usage references only; the two new themes supply their own Switch materials.
const USAGE: StringName = &"components.switch"
static var ELEMENTS: Dictionary = _elements()


static func _elements() -> Dictionary:
	var elements := {}
	for compact in [false, true]:
		var suffix := ".compact" if compact else ""
		var properties := {"base_type": &"Button"}
		properties["colors/ink_shadow"] = "switch.ink_shadow"
		properties["constants/ink_shadow_size"] = "switch.ink_shadow_size"
		properties["icons/selection_mark"] = "choice.check"
		properties["colors/selection_disabled"] = "choice.selection_disabled"
		for role in ["title", "description"]:
			properties["fonts/" + role + "_font"] = "switch." + role + ".font"
			properties["font_sizes/" + role + "_size"] = "switch." + role + ".size" + suffix
			for state in ["normal", "hover", "pressed", "hover_pressed", "disabled", "selected"]:
				properties["colors/" + role + "_" + state] = "switch." + role + "." + state
		for metric in ["minimum_height", "padding_x", "padding_y", "copy_gap", "selection_gap", "copy_minimum_width"]:
			properties["constants/" + metric] = "switch." + metric + suffix
		for state in ["normal", "hover", "pressed", "hover_pressed", "disabled", "focus"]:
			properties["styles/" + state] = "switch." + state + suffix
		elements[String(USAGE) + ("@compact" if compact else "")] = properties
		var group := {"base_type": &"MarginContainer"}
		for side in ["left", "top", "right", "bottom"]:
			group["constants/margin_" + side] = "switch.group.padding" + suffix
		elements["components.switch.group" + ("@compact" if compact else "")] = group
		elements["components.switch.options" + ("@compact" if compact else "")] = {
			"base_type": &"BoxContainer",
			"constants/separation": "switch.group.gap" + suffix,
			"constants/minimum_option_width": "switch.group.option_width" + suffix,
		}
	return elements
