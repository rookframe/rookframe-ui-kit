@tool
extends RefCounted
## Height of a record row at a width, measured from its own Controls.
##
## Godot does not lay out hidden Controls, so a row on another page keeps the
## width of its last layout (or none) and its wrapped labels would report a
## stale minimum height. The copy labels are sized to the width the row's
## HBoxContainer will give them, and their own minimum height is measured
## there (ADR-0017). Insets, gaps, fonts and line spacing are the ones the
## Controls resolve, so the measure holds in every Theme.

## `inset` wraps `box`; `copy` is the wrapping column inside `box`.
static func height(inset: MarginContainer, box: HBoxContainer, copy: BoxContainer, width: float) -> float:
	var copy_room := copy_width(box, copy, width - inset.get_theme_constant("margin_left") - inset.get_theme_constant("margin_right"))
	var copy_height := 0.0
	var lines := 0
	for child in copy.get_children():
		var control := child as Control
		if control == null or not control.visible or control.top_level: continue
		if control is Label: control.size.x = copy_room
		copy_height += control.get_minimum_size().max(control.custom_minimum_size).y
		lines += 1
	copy_height += copy.get_theme_constant("separation") * maxi(0, lines - 1)
	var content := maxf(copy_height, copy.custom_minimum_size.y)
	for child in box.get_children():
		var control := child as Control
		if control != null and control != copy and control.visible and not control.top_level:
			content = maxf(content, control.get_combined_minimum_size().y)
	return ceilf(content + inset.get_theme_constant("margin_top") + inset.get_theme_constant("margin_bottom"))

## The width BoxContainer gives the copy: fixed siblings keep their minimum
## width and expanding siblings share the rest by stretch ratio.
static func copy_width(box: HBoxContainer, copy: Control, width: float) -> float:
	var expanding: Array[Control] = [copy]
	var shown := 0
	for child in box.get_children():
		var control := child as Control
		if control == null or not control.visible or control.top_level: continue
		shown += 1
		if control == copy: continue
		if control.size_flags_horizontal & Control.SIZE_EXPAND: expanding.append(control)
		else: width -= control.get_combined_minimum_size().x
	width -= box.get_theme_constant("separation") * maxi(0, shown - 1)
	var ratio := 0.0
	for control in expanding: ratio += control.size_flags_stretch_ratio
	var settled := false
	while not settled:
		settled = true
		for control in expanding:
			var minimum := control.get_combined_minimum_size().x
			if control != copy and width * control.size_flags_stretch_ratio / ratio < minimum:
				width -= minimum
				ratio -= control.size_flags_stretch_ratio
				expanding.erase(control)
				settled = false
				break
	return maxf(1.0, maxf(copy.custom_minimum_size.x, width * copy.size_flags_stretch_ratio / ratio))
