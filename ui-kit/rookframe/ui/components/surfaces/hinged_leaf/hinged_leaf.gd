extends Control
## A leather leaf with persistent bindings and ordinary, live Godot Controls.
## Author children in Surface/Viewport/Root/Ink/Content, or use get_content().
## Position and size this Control normally; the hinge folds toward its lower edge.

@export_range(0.0, 48.0) var hinge_gap := 26.0
@export_range(12.0, 100.0) var hinge_inset := 48.0
@export var reduced_motion := false
signal settled(open: bool)
signal reaction_changed(offset: float)

const OPEN_SECONDS := 0.80
const CHOREOGRAPHY_SECONDS := 0.62
const CLOSED_ANGLE := -178.0
const MARGIN := Vector2(110, 150)
var is_open := false
var animating := false
var _motion: Tween
var _generation := 0
var _progress := 0.0
var _depth := 0.0
var _jolt := 0.0
@onready var _surface: SubViewportContainer = $Surface
@onready var _source: SubViewport = $Surface/Viewport
@onready var _root: Control = $Surface/Viewport/Root
@onready var _ink: ShaderMaterial = $Surface/Viewport/Root/Ink.material
@onready var _render: SubViewport = $Motion
@onready var _camera: Camera3D = $Motion/Camera
@onready var _pivot: Node3D = $Motion/Hinge
@onready var _body: Node3D = $Motion/Hinge/Leather
@onready var _image: TextureRect = $MovingLeather
@onready var _shadow: ColorRect = $Shadow
@onready var _bindings: Control = $Bindings

func get_content() -> Control:
	return $Surface/Viewport/Root/Ink/Content

func _ready() -> void:
	$Motion/Hinge/Leather/Face.material_override.albedo_texture = _source.get_texture()
	_image.texture = _render.get_texture()
	resized.connect(_layout)
	visibility_changed.connect(_visibility_changed)
	_source.gui_focus_changed.connect(_content_focus_changed)
	_layout()
	_folded()

func _layout() -> void:
	if not is_node_ready() or size.x <= 0 or size.y <= 0:
		return
	var render_size := size + MARGIN * 2
	_source.size = Vector2i(size * 2)
	_surface.size = size * 2
	_root.size = size
	get_content().size = size
	_render.size = Vector2i(render_size * 2)
	_image.position = -MARGIN
	_image.size = render_size
	_shadow.position = -MARGIN
	_shadow.size = render_size
	_camera.fov = rad_to_deg(2.0 * atan((render_size.y / 2) / 1200.0))
	_pivot.position.y = -size.y / 2 - hinge_gap
	$Motion/Hinge/Leather/Face.mesh.size = size
	$Motion/Hinge/Leather/Face.position.y = size.y / 2 + hinge_gap
	$Motion/Hinge/Leather/Thickness.mesh.size = Vector3(maxf(1, size.x - 3), maxf(1, size.y - 4), 1.8)
	$Motion/Hinge/Leather/Thickness.position.y = size.y / 2 + hinge_gap
	if is_open:
		_pose(_progress)
	elif not animating:
		_surface_pose(CLOSED_ANGLE, 0.0)

func set_open(value: bool, animated := true) -> void:
	_generation += 1
	if _motion != null and _motion.is_valid():
		_motion.kill()
	is_open = value
	animating = false
	if not is_node_ready():
		return
	if not animated or reduced_motion or _ink == null or not is_visible_in_tree():
		if value: _pose(1.0)
		else: _folded()
		if value: _focus_content.call_deferred()
		settled.emit(value)
		return
	if value:
		animating = true
		_surface.show()
		_surface.self_modulate.a = 0.0
		_source.gui_disable_input = true
		mouse_filter = Control.MOUSE_FILTER_STOP
		_begin_open.call_deferred(_generation)
	else:
		_begin_close()

func _begin_open(generation: int) -> void:
	if generation != _generation or not is_inside_tree(): return
	# Let Containers settle before sizing the live viewport; no stale-frame flash.
	await get_tree().process_frame
	if generation != _generation or not is_inside_tree(): return
	_layout()
	_pose(0.0)
	_motion = create_tween()
	_motion.tween_method(_pose, 0.0, 1.0, OPEN_SECONDS)
	_motion.tween_callback(func():
		animating = false
		_focus_content()
		settled.emit(true))

func _focus_content() -> void:
	if not is_open or animating or not is_visible_in_tree(): return
	# SubViewports have independent focus chains. Transfer focus into the live
	# Controls after the animated face settles.
	var first := get_content().find_next_valid_focus()
	if first != null:
		first.grab_focus()

func _content_focus_changed(control: Control) -> void:
	# Stock SubViewportContainer forwards keys in _unhandled_input by default.
	# While its child owns focus, forward in _input instead, before the parent
	# viewport treats Tab as navigation into its own unrelated focus chain.
	_surface.set_process_input(true)
	_surface.set_process_unhandled_input(false)
	control.focus_exited.connect(_content_focus_exited, CONNECT_ONE_SHOT)

func _content_focus_exited() -> void:
	_surface.set_process_input(false)
	_surface.set_process_unhandled_input(true)

func _pose(value: float) -> void:
	_progress = value
	_source.gui_disable_input = value < 1.0
	_surface.mouse_filter = Control.MOUSE_FILTER_IGNORE if value < 1.0 else Control.MOUSE_FILTER_STOP
	mouse_filter = Control.MOUSE_FILTER_STOP if value < 1.0 else Control.MOUSE_FILTER_IGNORE
	_surface.show()
	if value >= 1.0:
		_image.hide()
		_render.render_target_update_mode = SubViewport.UPDATE_DISABLED
		_source.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		_surface.self_modulate.a = 1.0
		_set_ink_progress(1.0)
		_surface_pose(0.0, 0.0)
		_shadow.hide()
		return
	_surface.self_modulate.a = 0.0
	_image.show()
	_render.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	_source.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	var seconds := value * CHOREOGRAPHY_SECONDS
	_set_ink_progress(clampf((seconds - 0.40) / 0.22, 0.0, 1.0))
	if seconds < 0.07:
		var t := seconds / 0.07
		_surface_pose(lerpf(CLOSED_ANGLE, -190.0, t), 0.0, Vector2.ONE, 0.0, sin(t * PI) * 1.3)
	elif seconds < 0.27:
		var t := (seconds - 0.07) / 0.20
		var lift := 1.0 - pow(1.0 - t, 2.4)
		_surface_pose(lerpf(-190.0, 16.0, lift), 130.0 * smoothstep(0.1, 1.0, t))
	elif seconds < 0.33:
		var t := (seconds - 0.27) / 0.06
		_surface_pose(lerpf(16.0, 12.0, t), lerpf(130.0, 142.0, t))
	elif seconds < 0.40:
		var t := pow((seconds - 0.33) / 0.07, 2.6)
		_surface_pose(lerpf(12.0, 0.0, t), lerpf(142.0, -9.0, t), Vector2(lerpf(1.0, 1.02, t), lerpf(1.0, 0.97, t)), 3.0 * t, 3.0 * t)
	elif seconds < 0.435:
		_surface_pose(0.0, -9.0, Vector2(1.02, 0.97), 3.0, 3.0)
	else:
		var t := (seconds - 0.435) / (CHOREOGRAPHY_SECONDS - 0.435)
		var impulse := sin(t * PI) * pow(1.0 - t, 1.4)
		var release := pow(1.0 - t, 3)
		_surface_pose(-4.0 * impulse, -9.0 * release + 60.0 * impulse, Vector2(1.0 + 0.02 * release, 1.0 - 0.03 * release), 3.0 * release - 2.0 * impulse, 3.0 * release - 2.2 * impulse)
		_shadow.modulate.a = pow(1.0 - t, 0.65)

func _surface_pose(angle: float, depth: float, compression := Vector2.ONE, dip := 0.0, jolt := 0.0) -> void:
	_depth = depth
	if not is_equal_approx(jolt, _jolt):
		reaction_changed.emit(jolt)
	_jolt = jolt
	_pivot.rotation_degrees.x = angle
	_body.position = _pivot.basis.inverse() * Vector3(0, -dip, depth)
	_body.scale = Vector3(compression.x, compression.y, 1)
	_image.self_modulate.a = smoothstep(-112.0, -88.0, angle)
	var extension := maxf(0.0, cos(deg_to_rad(angle)))
	for i in range(2):
		var binding: TextureRect = _bindings.get_child(i)
		var base := Vector2(hinge_inset if i == 0 else size.x - hinge_inset, size.y + hinge_gap + 8 + jolt)
		var top := base - Vector2(0, 20)
		var attachment := Vector3(base.x - size.x / 2, hinge_gap + 12, 1)
		top = top.lerp(_camera.unproject_position(_body.to_global(attachment)) * 0.5 - MARGIN, extension)
		var height := maxf(12.0, base.y - top.y)
		binding.size = Vector2(34, height)
		binding.position = Vector2(base.x - 17, top.y)
		if binding.material != null: binding.material.set_shader_parameter("strip_height", height)
		if binding.material != null: binding.material.set_shader_parameter("top_offset", top.x - base.x)
		binding.self_modulate = _binding_tint(extension)
	var loft := clampf(depth / 142.0, 0.0, 1.0)
	var exposure := smoothstep(-105.0, -60.0, angle)
	if _shadow.material == null: return
	_shadow.visible = exposure > 0.001
	_shadow.modulate.a = 1.0
	var corners := [Vector3(-size.x / 2, hinge_gap + size.y, 1), Vector3(size.x / 2, hinge_gap + size.y, 1), Vector3(size.x / 2, hinge_gap, 1), Vector3(-size.x / 2, hinge_gap, 1)]
	for i in range(4):
		var projected := _camera.unproject_position(_body.to_global(corners[i])) * 0.5
		_shadow.material.set_shader_parameter("corner_%d" % i, projected + Vector2(0, 3 + 18 * loft))
	_shadow.material.set_shader_parameter("softness", lerpf(4.0, 22.0, loft))
	_shadow.material.set_shader_parameter("opacity", lerpf(0.52, 0.27, loft) * exposure)

func _begin_close() -> void:
	_source.gui_release_focus()
	if not _surface.visible:
		_folded()
		return
	animating = true
	_source.gui_disable_input = true
	_surface.mouse_filter = Control.MOUSE_FILTER_IGNORE
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var from_angle := _pivot.rotation_degrees.x
	var from_depth := _depth
	var from_scale := Vector2(_body.scale.x, _body.scale.y)
	_motion = create_tween()
	_motion.tween_method(func(value: float): _set_ink_progress(value), float(_ink.get_shader_parameter("progress")), 0.0, 0.06)
	_motion.tween_callback(func():
		_surface.self_modulate.a = 0.0
		_image.show()
		_source.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		_render.render_target_update_mode = SubViewport.UPDATE_ALWAYS)
	_motion.tween_method(func(t: float): _surface_pose(lerpf(from_angle, CLOSED_ANGLE, t), lerpf(from_depth, 0.0, t), from_scale.lerp(Vector2.ONE, t)), 0.0, 1.0, 0.18).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_motion.tween_callback(func():
		_folded()
		settled.emit(false))

func _folded() -> void:
	_source.gui_release_focus()
	animating = false
	_progress = 0.0
	_surface.hide()
	_image.hide()
	_render.render_target_update_mode = SubViewport.UPDATE_DISABLED
	_source.render_target_update_mode = SubViewport.UPDATE_DISABLED
	_set_ink_progress(0.0)
	_surface_pose(CLOSED_ANGLE, 0.0)
	_shadow.hide()
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _visibility_changed() -> void:
	if is_node_ready() and not is_visible_in_tree():
		set_open(false, false)

func _exit_tree() -> void:
	_generation += 1
	if _motion != null and _motion.is_valid(): _motion.kill()
	if not is_zero_approx(_jolt): reaction_changed.emit(0.0)

func _binding_tint(_extension: float) -> Color:
	return Color.WHITE

func _set_ink_progress(progress: float) -> void:
	if _ink != null: _ink.set_shader_parameter("progress", progress)
