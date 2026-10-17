extends RefCounted

const Demo = preload("res://examples/components/pages/layout_surfaces/demo.gd")

static func build(page) -> void:
	for follow in [true, false]:
		var body = page.section("Keyboard focus follows" if follow else "Read-only history", "This bounded example owns its body scroll. Horizontal scrolling is disabled.")
		var bounds := Demo.region(body, 240)
		var scroll := preload("res://rookframe/ui/components/layout/scroll_area.tscn").instantiate() as ScrollContainer
		scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		scroll.follow_focus = follow
		bounds.add_child(scroll)
		scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		scroll.get_v_scroll_bar().custom_minimum_size.x = 16
		var content := Demo.stack(scroll)
		for index in 12:
			if follow:
				page.button(content, "Entry %02d · open details" % (index + 1))
			else:
				page.note(content, "Day %02d · The expedition recorded another landmark along the northern road." % (index + 1))
		var actions = page.flow(body)
		page.button(actions, "Scroll to top", func(): scroll.scroll_vertical = 0)
		page.button(actions, "Scroll to end", func(): scroll.scroll_vertical = int(scroll.get_v_scroll_bar().max_value))
