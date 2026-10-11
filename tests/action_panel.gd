extends GdUnitTestSuite
const PANEL = preload("res://rookframe/ui/components/surfaces/action_panel/action_panel.tscn")
const SECTION = preload("res://rookframe/ui/components/surfaces/action_panel/action_section.tscn")

func test_native_slots_grow_and_shrink_without_recreating_content() -> void:
	var panel = auto_free(PANEL.instantiate())
	panel.custom_minimum_size.x = 520
	add_child(panel)
	var title := Label.new()
	title.text = "A system-authored action"
	panel.get_header_slot().add_child(title)
	var first = SECTION.instantiate()
	var row := Label.new()
	row.text = "A system-authored roll"
	first.add_child(row)
	panel.get_sections_slot().add_child(first)
	await await_idle_frame()
	var before: float = panel.get_combined_minimum_size().y
	var second = SECTION.instantiate()
	var cost := SpinBox.new()
	cost.min_value = 5
	cost.max_value = 20
	cost.step = 5
	second.add_child(cost)
	panel.get_sections_slot().add_child(second)
	await await_idle_frame()
	assert_float(panel.get_combined_minimum_size().y).is_greater(before)
	assert_object(panel.get_sections_slot().get_child(0)).is_same(first)
	assert_object(cost.get_parent()).is_same(second)
	second.hide()
	await await_idle_frame()
	assert_float(panel.get_combined_minimum_size().y).is_equal(before)

func test_compact_and_footer_changes_preserve_controls_and_input() -> void:
	var panel = auto_free(PANEL.instantiate())
	add_child(panel)
	var target := Button.new()
	target.text = "Target"
	panel.get_footer_slot().add_child(target)
	await await_idle_frame()
	var height: float = panel.get_combined_minimum_size().y
	panel.show_footer = false
	await await_idle_frame()
	assert_bool(target.is_visible_in_tree()).is_false()
	assert_float(panel.get_combined_minimum_size().y).is_less(height)
	panel.compact = true
	panel.show_footer = true
	panel.show_emblem = false
	await await_idle_frame()
	assert_object(panel.get_footer_slot().get_child(0)).is_same(target)
	assert_bool(target.is_visible_in_tree()).is_true()
	assert_int(panel.mouse_filter).is_equal(Control.MOUSE_FILTER_IGNORE)

func test_roll_states_share_one_crisp_image_and_change_material() -> void:
	var theme = preload("res://rookframe/ui/theme/action_panel_theme.tres")
	var normal: StyleBoxTexture = theme.get_stylebox("normal", "RookframeActionRoll")
	for state in ["hover", "pressed", "disabled"]:
		var style: StyleBoxTexture = theme.get_stylebox(state, "RookframeActionRoll")
		assert_object(style.texture).is_same(normal.texture)
		assert_bool(style.modulate_color == normal.modulate_color).is_false()
