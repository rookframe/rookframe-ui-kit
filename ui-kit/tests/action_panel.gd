extends GdUnitTestSuite
const PANEL = preload("res://rookframe/ui/silkbound-ledger/components/surfaces/action_panel/action_panel.tscn")
const SECTION = preload("res://rookframe/ui/silkbound-ledger/components/surfaces/action_panel/action_section.tscn")

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

func test_footer_keeps_actions_clear_of_the_stepped_edge(compact: bool, _test_parameters := [[false], [true]]) -> void:
	var panel = auto_free(PANEL.instantiate())
	panel.compact = compact
	panel.custom_minimum_size.x = 320 if compact else 520
	add_child(panel)
	var row := HBoxContainer.new()
	var name := Label.new()
	name.text = "Target"
	name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(name)
	var action := Button.new()
	action.custom_minimum_size = Vector2(44, 44)
	action.theme_type_variation = &"RookframeActionIcon"
	row.add_child(action)
	panel.get_footer_slot().add_child(row)
	for i in range(5): await await_idle_frame()
	var leaf: Control = panel.get_node("Footer/Leaf")
	assert_float(action.get_global_rect().end.x).is_less_equal(leaf.get_global_rect().end.x - 28.0)
	assert_float(action.size.x).is_greater_equal(44.0)

func _animated_panel():
	var panel = auto_free(PANEL.instantiate())
	panel.custom_minimum_size.x = 520
	var section = SECTION.instantiate()
	var button := Button.new()
	button.text = "Prepare attack"
	section.add_child(button)
	panel.get_sections_slot().add_child(section)
	var target := Label.new()
	target.text = "Choose a target"
	panel.get_footer_slot().add_child(target)
	add_child(panel)
	var motion = panel.get_node("DropMotion")
	for i in range(20):
		await await_idle_frame()
		if motion._tween != null: break
	if motion._tween != null: motion._tween.pause()
	return panel

func test_drop_finishes_both_leaves_before_revealing_content() -> void:
	var panel = await _animated_panel()
	var motion = panel.get_node("DropMotion")
	var body = panel.get_sections_slot().get_child(0)
	var button = body.get_child(1)
	var footer = panel.get_node("Footer/Leaf")
	motion._pose(0.27)
	assert_float(motion._visuals[0].angle).is_greater(0.0)
	assert_bool(body.get_node("Skin").visible).is_false()
	assert_bool(footer.get_node("Skin").visible).is_false()
	assert_bool(motion.connector_visible(2)).is_false()
	assert_float(button.material.get_shader_parameter("progress")).is_equal(0.0)
	motion._pose(0.53)
	assert_bool(body.get_node("Skin").visible).is_true()
	assert_bool(footer.get_node("Skin").visible).is_false()
	assert_float(button.material.get_shader_parameter("progress")).is_equal(0.0)
	motion._pose(1.06)
	assert_bool(footer.get_node("Skin").visible).is_true()
	assert_float(button.material.get_shader_parameter("progress")).is_greater(0.0)
	assert_int(button.get_mouse_filter_with_override()).is_equal(Control.MOUSE_FILTER_IGNORE)
	button.self_modulate = Color.RED # A target update during the reveal must survive.
	motion.finish()
	assert_object(body.get_child(1)).is_same(button)
	assert_object(button.material).is_null()
	assert_int(button.get_mouse_filter_with_override()).is_equal(Control.MOUSE_FILTER_STOP)
	assert_bool(button.self_modulate == Color.RED).is_true()

func test_entrance_cancels_cleanly_on_structure_change_and_hide() -> void:
	var panel = await _animated_panel()
	var motion = panel.get_node("DropMotion")
	var body = panel.get_sections_slot().get_child(0)
	panel.show_footer = false
	motion._pose(0.3)
	assert_bool(motion.active).is_false()
	assert_bool(body.get_node("Skin").visible).is_true()
	assert_object(body.get_child(1).material).is_null()
	panel.hide()
	panel.show()
	for i in range(8): await await_idle_frame()
	assert_bool(motion.active).is_true()
	panel.hide()
	assert_bool(motion.active).is_false()
	assert_int(body.mouse_behavior_recursive).is_equal(Control.MOUSE_BEHAVIOR_INHERITED)
	assert_object(body.get_child(1).material).is_null()
	panel.reduced_motion = true
	panel.show()
	await await_idle_frame()
	assert_bool(motion.active).is_false()
	assert_float(panel.modulate.a).is_equal(1.0)

func test_cancel_before_layout_restores_visibility_without_allocating_faces() -> void:
	var panel = auto_free(PANEL.instantiate())
	add_child(panel)
	var motion = panel.get_node("DropMotion")
	panel.hide()
	for i in range(5): await await_idle_frame()
	assert_bool(motion.active).is_false()
	assert_int(motion.get_child_count()).is_equal(0)
	assert_float(panel.modulate.a).is_equal(1.0)

func test_replaced_choice_controls_during_ink_restore_without_stale_references() -> void:
	var panel = await _animated_panel()
	var motion = panel.get_node("DropMotion")
	var body = panel.get_sections_slot().get_child(0)
	var old = body.get_child(1)
	body.remove_child(old)
	old.queue_free()
	var choice := OptionButton.new()
	choice.add_item("Melee")
	body.add_child(choice)
	await await_idle_frame()
	motion._pose(1.06)
	assert_object(choice.material).is_not_null()
	motion.finish()
	assert_object(choice.material).is_null()
	assert_int(choice.get_mouse_filter_with_override()).is_equal(choice.mouse_filter)

func test_detaching_before_deferred_entrance_does_not_access_a_tree() -> void:
	var panel = auto_free(PANEL.instantiate())
	add_child(panel)
	remove_child(panel)
	for i in range(5): await await_idle_frame()
	assert_bool(panel.get_node("DropMotion").active).is_false()

func test_detaching_hud_leaf_before_deferred_open_does_not_access_a_tree() -> void:
	var leaf = auto_free(load("res://rookframe/ui/silkbound-ledger/components/surfaces/hinged_leaf/hinged_leaf.tscn").instantiate())
	add_child(leaf)
	leaf.set_open(true)
	remove_child(leaf)
	for i in range(5): await await_idle_frame()
	assert_bool(leaf.is_inside_tree()).is_false()
