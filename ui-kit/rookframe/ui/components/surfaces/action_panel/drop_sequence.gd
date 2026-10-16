extends Node2D
## An entrance only: native slots, layout, input and control identity stay intact.
const VISUAL = preload("res://rookframe/ui/components/surfaces/action_panel/drop_leaf.tscn")
@export var visual_scene: PackedScene = VISUAL
@export var ink_shader: Shader
const LEAF = preload("res://rookframe/ui/components/surfaces/action_panel/action_leaf.gd")
const HEADER_SECONDS := 0.02
const DROP_SECONDS := 0.46
const INK_SECONDS := 0.24
var active := false
var elapsed := 0.0
var _generation := 0
var _tween: Tween
var _leaves: Array[Control] = []
var _visuals: Array[Control] = []
var _content := {}
var _skins := {}
var _input := {}
var _ink := ShaderMaterial.new()
var _original_modulate := Color.WHITE
@onready var panel: VBoxContainer = get_parent()

func _ready() -> void:
	_ink.shader = ink_shader
	panel.visibility_changed.connect(_visibility_changed)
	if panel.animate_open and not Engine.is_editor_hint():
		open()

func open() -> void:
	finish()
	if ink_shader == null or panel.reduced_motion or not panel.is_visible_in_tree(): return
	active = true
	elapsed = 0.0
	_original_modulate = panel.modulate
	panel.modulate.a = 0.0
	_generation += 1
	_begin.call_deferred(_generation)

func _begin(generation: int) -> void:
	if generation != _generation or not is_inside_tree() or not active: return
	# Let native Containers finish the caller's initial content and compact layout.
	await get_tree().process_frame
	if generation != _generation or not is_inside_tree() or not active: return
	_leaves = panel.linked_leaves()
	for leaf in _leaves:
		_input[leaf] = [leaf.mouse_behavior_recursive, leaf.focus_behavior_recursive]
		leaf.mouse_behavior_recursive = Control.MOUSE_BEHAVIOR_DISABLED
		leaf.focus_behavior_recursive = Control.FOCUS_BEHAVIOR_DISABLED
		if leaf != _leaves[0]:
			var visual = visual_scene.instantiate()
			add_child(visual)
			_visuals.append(visual)
			var skin: CanvasItem = leaf.get_node_or_null("Skin")
			if skin != null:
				_skins[skin] = skin.visible
				skin.hide()
	var emblem: Control = panel.get_node("Header/Emblem/Leaf")
	if panel.show_emblem:
		_input[emblem] = [emblem.mouse_behavior_recursive, emblem.focus_behavior_recursive]
		emblem.mouse_behavior_recursive = Control.MOUSE_BEHAVIOR_DISABLED
		emblem.focus_behavior_recursive = Control.FOCUS_BEHAVIOR_DISABLED
		_sync_ink(emblem)
	for leaf in _leaves: _sync_ink(leaf)
	_pose(0.0)
	# Respond with the blank header while the faces warm; do not hide cold setup.
	panel.modulate = _original_modulate
	await RenderingServer.frame_post_draw
	# Give the GPU's new targets a complete frame before advancing the drop clock.
	await RenderingServer.frame_post_draw
	if generation != _generation or not active: return
	_tween = create_tween()
	_tween.tween_method(_pose, 0.0, HEADER_SECONDS + DROP_SECONDS * _visuals.size() + INK_SECONDS, HEADER_SECONDS + DROP_SECONDS * _visuals.size() + INK_SECONDS)
	_tween.tween_callback(finish)

func _pose(seconds: float) -> void:
	# A live consequence or section change should immediately show its native state.
	if panel.linked_leaves() != _leaves:
		finish()
		return
	elapsed = seconds
	var ink_progress := clampf((seconds - HEADER_SECONDS - DROP_SECONDS * _visuals.size()) / INK_SECONDS, 0, 1)
	_ink.set_shader_parameter("progress", ink_progress)
	for leaf in _leaves:
		if is_instance_valid(leaf): _sync_ink(leaf)
	if panel.show_emblem: _sync_ink(panel.get_node("Header/Emblem/Leaf"))
	for i in range(_visuals.size()):
		var leaf := _leaves[i + 1]
		if not is_instance_valid(leaf):
			finish()
			return
		var visual = _visuals[i]
		var progress := clampf((seconds - HEADER_SECONDS - i * DROP_SECONDS) / DROP_SECONDS, 0, 1)
		var rect := Rect2(leaf.global_position - panel.global_position, leaf.size)
		visual.configure(rect, leaf.get_surface_style() if leaf is LEAF else leaf.get_theme_stylebox("panel"))
		visual.pose(progress)
		visual.visible = progress > 0.0 and progress < 1.0
		var skin := leaf.get_node_or_null("Skin")
		if skin != null: skin.visible = progress >= 1.0 and _skins.get(skin, true)
	for item in _content:
		if is_instance_valid(item) and _content[item][0] != null:
			item.self_modulate.a = _content[item][2].a * ink_progress
	panel.get_node("Connectors").queue_redraw()

func _sync_ink(root: Node) -> void:
	for child in root.get_children():
		if child.name == "Skin" or child is Window or child is SubViewport: continue
		if child is CanvasItem and not _content.has(child):
			_content[child] = [child.material, child.use_parent_material, child.self_modulate]
			# Respect custom effects; those controls use an alpha reveal instead.
			if child.material == null:
				child.use_parent_material = false
				child.material = _ink
			else:
				child.self_modulate.a = 0.0
		_sync_ink(child)

func connector_visible(index: int) -> bool:
	return not active or elapsed >= HEADER_SECONDS + (index - 1) * DROP_SECONDS

func attachment(index: int, point: Vector2) -> Vector2:
	if active and index > 0 and index <= _visuals.size():
		var progress := clampf((elapsed - HEADER_SECONDS - (index - 1) * DROP_SECONDS) / DROP_SECONDS, 0, 1)
		if progress < 1.0:
			var visual = _visuals[index - 1]
			return visual.position + visual.project(point)
	return _leaves[index].global_position - panel.global_position + point

func finish() -> void:
	_generation += 1
	if _tween != null and _tween.is_valid(): _tween.kill()
	if not active: return
	active = false
	panel.modulate = _original_modulate
	for item in _content:
		if not is_instance_valid(item): continue
		item.material = _content[item][0]
		item.use_parent_material = _content[item][1]
		if _content[item][0] != null: item.self_modulate = _content[item][2]
	for skin in _skins:
		if is_instance_valid(skin): skin.visible = _skins[skin]
	for leaf in _input:
		if not is_instance_valid(leaf): continue
		leaf.mouse_behavior_recursive = _input[leaf][0]
		leaf.focus_behavior_recursive = _input[leaf][1]
	for visual in _visuals:
		if is_instance_valid(visual):
			visual.hide()
			visual.queue_free()
	_content.clear()
	_skins.clear()
	_input.clear()
	_visuals.clear()
	_leaves.clear()
	panel.get_node("Connectors").queue_redraw()

func _visibility_changed() -> void:
	if not panel.is_visible_in_tree(): finish()
	elif panel.animate_open and not Engine.is_editor_hint(): open()

func _exit_tree() -> void:
	finish()
