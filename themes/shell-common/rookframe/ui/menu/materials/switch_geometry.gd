extends RefCounted
## Shared physical hit targets and copy spacing, independent of material.


static func values() -> Dictionary:
	var result := {}
	for compact in [false, true]:
		var suffix := ".compact" if compact else ""
		result["switch.title.size" + suffix] = 20 if compact else 24
		result["switch.description.size" + suffix] = 16 if compact else 18
		result["switch.minimum_height" + suffix] = 88 if compact else 116
		result["switch.padding_x" + suffix] = 20 if compact else 26
		result["switch.padding_y" + suffix] = 16 if compact else 22
		result["switch.copy_gap" + suffix] = 4 if compact else 6
		result["switch.selection_gap" + suffix] = 16 if compact else 24
		result["switch.copy_minimum_width" + suffix] = 100 if compact else 120
		result["switch.group.padding" + suffix] = 16 if compact else 24
		result["switch.group.gap" + suffix] = 12 if compact else 16
		result["switch.group.option_width" + suffix] = 280 if compact else 320
	return result
