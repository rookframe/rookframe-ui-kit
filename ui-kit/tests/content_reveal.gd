extends GdUnitTestSuite
const INK = preload("res://rookframe/ui/components/surfaces/action_panel/content_ink.gdshader")
const REVEAL = preload("res://rookframe/ui/_internal/surfaces/content_reveal.gd")

func test_reveal_restores_material_focus_and_modulation_after_interruption() -> void:
	var content: Control = auto_free(Control.new())
	var button := Button.new()
	button.text = "Retained action"
	content.add_child(button)
	add_child(content)
	button.grab_focus()
	var first = REVEAL.new()
	first.shader = INK
	var second = REVEAL.new()
	second.shader = INK
	var original := button.self_modulate
	first.play(content)
	assert_object(button.material).is_not_null()
	assert_bool(button.has_focus()).is_true()
	second.play(button)
	assert_object(content.material).is_null()
	assert_object(button.material).is_not_null()
	second.finish()
	assert_object(button.material).is_null()
	assert_bool(button.self_modulate == original).is_true()
	assert_bool(button.has_focus()).is_true()
	first.play(content)
	content.hide()
	assert_object(button.material).is_null()
	content.show()
	first.play(content, true)
	assert_object(button.material).is_null()

func test_reveal_uses_four_hundred_milliseconds_and_preserves_existing_shader() -> void:
	var content: Control = auto_free(Control.new())
	var custom := ShaderMaterial.new()
	content.material = custom
	content.self_modulate = Color(1,1,1,0.6)
	add_child(content)
	var reveal = REVEAL.new()
	reveal.shader = INK
	reveal.play(content)
	await get_tree().create_timer(0.2).timeout
	assert_float(content.self_modulate.a).is_less(0.6)
	assert_bool(content.material == custom).is_true()
	await get_tree().create_timer(0.25).timeout
	assert_float(content.self_modulate.a).is_equal_approx(0.6, 0.00001)
	assert_bool(content.material == custom).is_true()

func test_wizard_reveals_step_changes_but_not_roll_progress_updates() -> void:
	var wizard: Control = auto_free(load("res://rookframe/ui/silkbound-ledger/components/surfaces/fullscreen_wizard.tscn").instantiate())
	wizard.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	add_child(wizard)
	wizard.size = Vector2(1024,768)
	var steps: Array[String] = ["Class", "Abilities", "Equipment"]
	wizard.configure("MÖRK BORG", "Create a character", steps)
	wizard.set_step(1)
	await get_tree().process_frame
	await get_tree().process_frame
	assert_object(wizard.get_stage_slot().material).is_not_null()
	await get_tree().create_timer(0.45).timeout
	wizard.set_step(1)
	wizard.set_primary("Roll Presence", false)
	await get_tree().process_frame
	assert_object(wizard.get_stage_slot().material).is_null()

func test_reading_leaf_preserves_grain_and_independent_border_after_resize() -> void:
	var frame: Control = auto_free(load("res://rookframe/ui/silkbound-ledger/components/surfaces/ledger_frame.tscn").instantiate())
	add_child(frame)
	for extent in [Vector2(1920,1080), Vector2(844,390)]:
		frame.set_sections(Rect2(12,12,extent.x-24,56), Rect2(12,80,extent.x-24,extent.y-92))
		await get_tree().process_frame
		var material: StyleBoxTexture = frame.get_node("Body/Skin/Surface").get_theme_stylebox("panel")
		assert_bool(material.draw_center).is_false()
		assert_bool(frame.get_node("Body/Skin/Grain").visible).is_true()

func test_dialog_open_reveals_content_and_close_cancels_it() -> void:
	var host: Control = auto_free(Control.new())
	add_child(host)
	var dialog = load("res://rookframe/ui/silkbound-ledger/components/overlays/dialog.tscn").instantiate()
	host.add_child(dialog)
	dialog.open_dialog()
	await get_tree().process_frame
	await get_tree().process_frame
	var content: Control = dialog.get_node("Shell/Content")
	assert_object(content.material).is_not_null()
	dialog.close_dialog()
	assert_object(content.material).is_null()
