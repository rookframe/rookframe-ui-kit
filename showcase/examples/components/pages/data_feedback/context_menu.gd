extends RefCounted

const Demo = preload("res://examples/components/pages/data_feedback/demo.gd")

static func build(page) -> void:
	for unavailable in [false, true]:
		var section = page.section("Record actions" if not unavailable else "Unavailable action", "Right-click the source or activate its button with touch, keyboard, or controller.")
		var source = page.button(section, "Journal actions" if not unavailable else "Locked journal actions")
		var status = page.note(section, "No action requested.")
		var menu := preload("res://rookframe/ui/components/overlays/context_menu.tscn").instantiate() as PopupMenu
		menu.theme = page.preview_theme
		menu.add_item("Inspect", 10)
		menu.add_item("Duplicate", 20)
		menu.add_separator()
		menu.add_item("Archive", 30)
		menu.set_item_disabled(3, unavailable)
		page.add_child(menu)
		var open_menu := func():
			menu.popup(Rect2i(source.get_screen_position() + Vector2(0, source.size.y), Vector2i(220, 0)))
			menu.set_focused_item(0)
		source.pressed.connect(open_menu)
		source.gui_input.connect(func(event: InputEvent):
			if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
				menu.popup(Rect2i(source.get_screen_position() + event.position, Vector2i(220, 0)))
				menu.set_focused_item(0)
				source.accept_event())
		menu.popup_hide.connect(func():
			if source.is_visible_in_tree(): source.grab_focus())
		menu.id_pressed.connect(func(id: int): status.text = {10: "Inspect requested.", 20: "Duplicate requested.", 30: "Archive requested."}[id])
