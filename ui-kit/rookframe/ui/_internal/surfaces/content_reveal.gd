extends RefCounted
## Shared, interruptible ink on native content. Layout, focus and input stay native.
const INK = preload("res://rookframe/ui/components/surfaces/action_panel/content_ink.gdshader")
const SECONDS := 0.4
const OWNER := &"_rookframe_content_reveal"
var _tween: Tween
var _items: Dictionary = {}
var _root: Control
var _material: ShaderMaterial

func play(content: Control, reduced_motion: bool = false) -> void:
	finish()
	if reduced_motion or Engine.is_editor_hint() or not content.is_visible_in_tree():
		return
	_root = content
	_material = ShaderMaterial.new()
	_material.shader = INK
	_collect(content)
	_root.tree_exiting.connect(finish, CONNECT_ONE_SHOT)
	_root.visibility_changed.connect(_visibility_changed)
	_pose(0.0)
	_tween = content.create_tween()
	_tween.tween_method(_pose, 0.0, 1.0, SECONDS)
	_tween.tween_callback(finish)

func _collect(node: Node) -> void:
	if node is Window or node is SubViewport or node.name == &"Skin":
		return
	if node is CanvasItem:
		if node.has_meta(OWNER):
			var previous = node.get_meta(OWNER).get_ref()
			if previous != null and previous != self: previous.finish()
		node.set_meta(OWNER, weakref(self))
		_items[node] = [node.material, node.use_parent_material, node.self_modulate]
		if node.material == null:
			node.use_parent_material = false
			node.material = _material
	for child in node.get_children():
		_collect(child)

func _pose(progress: float) -> void:
	_material.set_shader_parameter("progress", progress)
	for item in _items:
		if is_instance_valid(item) and _items[item][0] != null:
			item.self_modulate.a = _items[item][2].a * progress

func finish() -> void:
	if _tween != null and _tween.is_valid():
		_tween.kill()
	_tween = null
	for item in _items:
		if is_instance_valid(item):
			item.remove_meta(OWNER)
			item.material = _items[item][0]
			item.use_parent_material = _items[item][1]
			item.self_modulate = _items[item][2]
	_items.clear()
	if is_instance_valid(_root):
		if _root.tree_exiting.is_connected(finish):
			_root.tree_exiting.disconnect(finish)
		if _root.visibility_changed.is_connected(_visibility_changed):
			_root.visibility_changed.disconnect(_visibility_changed)
	_root = null

func _visibility_changed() -> void:
	if is_instance_valid(_root) and not _root.is_visible_in_tree():
		finish()
