extends GdUnitTestSuite

const FANTASY = preload("res://rookframe/ui/menu/MenuTheme.tres")
const CYBERPUNK = preload("res://rookframe/ui/menu/cyberpunk/CyberpunkTheme.tres")
const Compiler = preload("res://rookframe/ui/menu/menu_theme.gd")

func test_public_themes_supply_world_rows_backdrop_and_tooltips() -> void:
	for appearance in [FANTASY, CYBERPUNK]:
		var row: Button = auto_free(Button.new())
		row.theme = appearance
		add_child(row)
		Compiler.apply_usages(row, [&"components.selectableRow", &"components.selectableRow@selected"], true)
		assert_object(row.get_theme_stylebox("pressed")).is_same(appearance.get_stylebox("pressed", "components_selectableRow__selected"))
		assert_object(row.get_theme_stylebox("focus")).is_same(appearance.get_stylebox("focus", "components_selectableRow"))
		assert_int(row.get_theme_font_size("font_size")).is_equal(appearance.get_font_size("font_size", "components_selectableRow__compact"))
		assert_bool(appearance.get_stylebox("panel", "world_escapeMenu_surface") is StyleBoxEmpty).is_true()
		assert_float(appearance.get_color("color", "components_backdrop").a).is_greater(0.0)

	assert_that(FANTASY.get_color("color", "components_backdrop")).is_not_equal(CYBERPUNK.get_color("color", "components_backdrop"))

func test_silkbound_ledger_supplies_the_world_menu_usages() -> void:
	# The host's Game menu names only usages. A theme that leaves them out draws a
	# zero-width column on an opaque backdrop.
	var appearance: Theme = load("res://rookframe/ui/themes/silkbound-ledger/theme.tres")
	assert_int(appearance.get_constant("surface_width", "world_escapeMenu_layout")).is_greater(0)
	assert_int(appearance.get_constant("breakpoint_compact", "world_escapeMenu_layout")).is_greater(0)
	assert_bool(appearance.get_stylebox("panel", "world_escapeMenu_surface") is StyleBoxEmpty).is_true()
	assert_bool(appearance.get_stylebox("panel", "world_escapeMenu_group") is StyleBoxTexture).is_true()
	var backdrop := appearance.get_color("color", "world_escapeMenu_backdrop")
	assert_that(backdrop).is_equal(appearance.get_color("scrim", "RookframeTokens"))
	assert_float(backdrop.a).is_between(0.01, 0.99)
	# The menu surface carries the Silkbound presentation Theme: the leaf must
	# resolve there too, composed from the ordered usages.
	var surface: Panel = auto_free(load("res://rookframe/ui/menu/MenuSurface.tscn").instantiate())
	var root: Control = auto_free(Control.new())
	root.theme = appearance
	add_child(root)
	root.add_child(surface)
	Compiler.apply_usages(surface, [&"menu.surface", &"menu.group", &"world.escapeMenu.group"])
	assert_object(surface.get_theme_stylebox("panel")).is_same(appearance.get_stylebox("panel", "world_escapeMenu_group"))

func test_ordered_primary_keeps_sparse_overrides_and_native_local_priority() -> void:
	for source in [FANTASY, CYBERPUNK]:
		var appearance: Theme = source.duplicate()
		var button: Button = auto_free(Button.new())
		button.theme = appearance
		add_child(button)
		var usages: Array[StringName] = [&"components.button", &"components.button.primary", &"menu.buttons", &"test.action"]
		var color := Color(0.2, 0.7, 0.4)
		appearance.set_color("font_color", &"test_action", color)
		appearance.set_constant("ornament_rest", &"test_action", 0)
		Compiler.apply_usages(button, usages, true)
		await get_tree().process_frame
		assert_that(button.get_theme_color("font_color")).is_equal(color)
		assert_int(button.get_theme_constant("ornament_rest")).is_zero()
		appearance.set_font_size("font_size", &"components_button__compact", 47)
		Compiler.apply_usages(button, usages, true)
		await get_tree().process_frame
		assert_int(button.get_theme_font_size("font_size")).is_equal(47)
		appearance.clear_color("font_color", &"test_action")
		Compiler.apply_usages(button, usages, true)
		await get_tree().process_frame
		assert_that(button.get_theme_color("font_color")).is_equal(appearance.get_color("font_color", "menu_button_primary__compact"))
		# A later primary usage overrides group ink even if its Material value
		# currently matches the standard style; token identity still matters.
		appearance.set_color("font_color", &"menu_buttons", color)
		Compiler.apply_usages(button, [&"components.button", &"menu.buttons", &"components.button.primary"])
		await get_tree().process_frame
		assert_that(button.get_theme_color("font_color")).is_equal(appearance.get_color("font_color", "menu_button_primary"))
		button.add_theme_color_override("font_color", color)
		Compiler.apply_usages(button, usages)
		await get_tree().process_frame
		assert_that(button.get_theme_color("font_color")).is_equal(color)

func test_world_tooltips_follow_partial_theme_changes_and_keep_explicit_overrides() -> void:
	var authored: Theme = FANTASY.duplicate()
	var target: Theme = FANTASY.duplicate()
	var ink := Color(0.2, 0.8, 0.4)
	authored.set_color("font_color", &"editor_body", ink)
	target.merge_with(authored)
	Compiler.apply_world_tooltips(target, authored)
	assert_that(target.get_color("font_color", &"TooltipLabel")).is_equal(ink)
	assert_object(target.get_stylebox("panel", &"TooltipPanel")).is_same(target.get_stylebox("panel", &"editor_surface_inset"))
	ink = Color(0.8, 0.2, 0.6)
	authored.set_color("font_color", &"editor_body", ink)
	target.merge_with(authored)
	Compiler.apply_world_tooltips(target, authored)
	assert_that(target.get_color("font_color", &"TooltipLabel")).is_equal(ink)
	authored.set_color("font_color", &"TooltipLabel", Color.WHITE)
	target.merge_with(authored)
	Compiler.apply_world_tooltips(target, authored)
	assert_that(target.get_color("font_color", &"TooltipLabel")).is_equal(Color.WHITE)
